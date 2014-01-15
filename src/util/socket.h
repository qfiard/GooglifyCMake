#ifndef UTIL_SOCKET_H_
#define UTIL_SOCKET_H_

#include <string>
#include "base/base.h"
#include "boost/asio.hpp"
#include "boost/bind.hpp"
#include "boost/detail/endian.hpp"
#include "boost/function.hpp"
#include "gflags/gflags.h"
#include "util/logging.h"

namespace util {

DECLARE_int32(max_buffer_size);

template <class MessageType, class SocketType>
class Socket {
 public:
  typedef boost::function<void(const MessageType&)> ReadCallback;
  typedef boost::function<void()> WriteCallback;
  static void ReadMessageFromSocket(SocketType* socket,
                                    const ReadCallback& callback);
  static void WriteMessageToSocket(const MessageType& message,
                                   SocketType* socket,
                                   const WriteCallback& callback);

 private:
  static void HandleMessageSent(const MessageType& message, SocketType* socket,
                                const WriteCallback& callback,
                                const boost::system::error_code& error,
                                std::size_t bytes_transferred);
  static void HandleSizeSent(const MessageType& message, SocketType* socket,
                             const WriteCallback& callback,
                             const boost::system::error_code& error,
                             std::size_t bytes_transferred);
  static void HandleWriteError(const boost::system::error_code& error);

  static void HandleSizeRead(SocketType* socket, boost::asio::streambuf* buffer,
                             const ReadCallback& callback,
                             const boost::system::error_code& error,
                             std::size_t num_bytes_read);
  static void HandleMessageRead(SocketType* socket,
                                boost::asio::streambuf* buffer,
                                const uint8_t& message_size,
                                const ReadCallback& callback,
                                const boost::system::error_code& error,
                                std::size_t num_bytes_read);
  static void Finalize(SocketType* socket, boost::asio::streambuf* buffer,
                       const MessageType& message,
                       const ReadCallback& callback);
  static void HandleReadError(const boost::system::error_code& error,
                              boost::asio::streambuf* buffer);

  DISALLOW_IMPLICIT_CONSTRUCTORS(Socket);
};

namespace socket {

template <class MessageType, class SocketType>
void ReadMessageFromSocket(
    SocketType* socket,
    const typename Socket<MessageType, SocketType>::ReadCallback& callback) {
  Socket<MessageType, SocketType>::ReadMessageFromSocket(socket, callback);
}

template <class MessageType, class SocketType>
void WriteMessageToSocket(
    const MessageType& message, SocketType* socket,
    const typename Socket<MessageType, SocketType>::WriteCallback& callback) {
  Socket<MessageType, SocketType>::WriteMessageToSocket(message, socket,
                                                        callback);
}

}  // namespace socket

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::WriteMessageToSocket(
    const MessageType& message, SocketType* socket,
    const WriteCallback& callback) {
  uint64_t size = message.ByteSize();
#if BOOST_BIG_ENDIAN
  size = __builtin_bswap64(size);
#endif
  boost::asio::async_write(
      *socket, boost::asio::buffer(&size, 8),
      boost::bind(&Socket<MessageType, SocketType>::HandleSizeSent, message,
                  socket, callback, boost::asio::placeholders::error,
                  boost::asio::placeholders::bytes_transferred));
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleSizeSent(
    const MessageType& message, SocketType* socket,
    const WriteCallback& callback, const boost::system::error_code& error,
    std::size_t bytes_transferred) {
  if (error) {
    HandleWriteError(error);
    return;
  }
  CHECK_EQ(8, bytes_transferred);
  boost::asio::async_write(
      *socket, boost::asio::buffer(message.SerializeAsString()),
      boost::bind(&Socket<MessageType, SocketType>::HandleMessageSent, message,
                  socket, callback, boost::asio::placeholders::error,
                  boost::asio::placeholders::bytes_transferred));
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleMessageSent(
    const MessageType& message, SocketType* socket,
    const WriteCallback& callback, const boost::system::error_code& error,
    std::size_t bytes_transferred) {
  if (error) {
    HandleWriteError(error);
    return;
  }
  CHECK_EQ(bytes_transferred, message.ByteSize());
  socket->get_io_service().post(callback);
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::ReadMessageFromSocket(
    SocketType* socket,
    const boost::function<void(const MessageType&)>& callback) {
  boost::asio::streambuf* buffer = new boost::asio::streambuf;
  boost::asio::streambuf::mutable_buffers_type mutable_buffer =
      buffer->prepare(8);
  socket->async_receive(
      mutable_buffer,
      boost::bind(&Socket<MessageType, SocketType>::HandleSizeRead, socket,
                  buffer, callback, boost::asio::placeholders::error,
                  boost::asio::placeholders::bytes_transferred));
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleSizeRead(
    SocketType* socket, boost::asio::streambuf* buffer,
    const boost::function<void(const MessageType&)>& callback,
    const boost::system::error_code& error, std::size_t num_bytes_read) {
  if (error && error != boost::asio::error::eof) {
    HandleReadError(error, buffer);
    return;
  }
  buffer->commit(num_bytes_read);
  if (buffer->size() < 8) {
    boost::asio::streambuf::mutable_buffers_type mutable_buffer =
        buffer->prepare(8 - buffer->size());
    socket->async_receive(
        mutable_buffer,
        boost::bind(&Socket<MessageType, SocketType>::HandleSizeRead, socket,
                    buffer, callback, boost::asio::placeholders::error,
                    boost::asio::placeholders::bytes_transferred));
    return;
  }
  CHECK_EQ(buffer->size(), 8);
  std::istream data_stream(buffer);
  std::string data;
  data_stream >> data;
  uint64_t size = *(reinterpret_cast<const uint64_t*>(data.data()));
#if BOOST_BIG_ENDIAN
  size = __builtin_bswap64(size);
#endif
  buffer->consume(8);
  boost::asio::streambuf::mutable_buffers_type mutable_buffer =
      buffer->prepare(size);
  socket->async_receive(
      mutable_buffer,
      boost::bind(&Socket<MessageType, SocketType>::HandleMessageRead, socket,
                  buffer, size, callback, boost::asio::placeholders::error,
                  boost::asio::placeholders::bytes_transferred));
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleMessageRead(
    SocketType* socket, boost::asio::streambuf* buffer,
    const uint8_t& message_size,
    const boost::function<void(const MessageType&)>& callback,
    const boost::system::error_code& error, std::size_t num_bytes_read) {
  if (error && error != boost::asio::error::eof) {
    HandleReadError(error, buffer);
    return;
  }
  buffer->commit(num_bytes_read);
  if (buffer->size() < message_size) {
    boost::asio::streambuf::mutable_buffers_type mutable_buffer =
        buffer->prepare(message_size - buffer->size());
    socket->async_receive(
        mutable_buffer,
        boost::bind(&Socket<MessageType, SocketType>::HandleMessageRead, socket,
                    buffer, message_size, callback,
                    boost::asio::placeholders::error,
                    boost::asio::placeholders::bytes_transferred));
    return;
  }
  CHECK_EQ(buffer->size(), message_size);
  MessageType message;
  std::istream is(buffer);
  if (!message.ParseFromIstream(&is)) {
    LOG(ERROR) << "Invalid data received.";
    HandleReadError(error, buffer);
    return;
  }
  Finalize(socket, buffer, message, callback);
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::Finalize(
    SocketType* socket, boost::asio::streambuf* buffer,
    const MessageType& message,
    const boost::function<void(const MessageType&)>& callback) {
  delete buffer;
  socket->get_io_service().post(boost::bind(callback, message));
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleReadError(
    const boost::system::error_code& error, boost::asio::streambuf* buffer) {
  LOG(ERROR) << error.message();
  delete buffer;
}

template <class MessageType, class SocketType>
void Socket<MessageType, SocketType>::HandleWriteError(
    const boost::system::error_code& error) {
  LOG(ERROR) << error.message();
}

}  // namespace util

#endif  // UTIL_SOCKET_H_
