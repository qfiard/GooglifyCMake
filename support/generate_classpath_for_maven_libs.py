#!/usr/bin/env python
## @file A script to parse the dependency tree of maven downloaded libraries
## and convert them to classpath files.
## @param[in] $1 Maven executable.
## @param[in] $2 Path to the pom.xml configuration file.
## @param[in] $3 Path to the directory containing the downloaded libraries.

import StringIO
import glob
import os.path
import re
import sets
import subprocess
import sys


class DependencyNode(object):
  def __init__(self, tree_line):
    self.level = (tree_line.find('-') - 8) / 3
    part = "([^:\s]*)"
    matches = re.search("{0}:{0}:{0}:{0}:{0}".format(part), tree_line)
    self.artifact_id = matches.group(2)
    self.packaging = matches.group(3)
    self.version = matches.group(4)
    self.archive_file = "%s-%s.%s" % (
        self.artifact_id, self.version, self.packaging)
    self.children = []

  def Treeify(self, node_list, node_index, parent):
    self.children = []
    i = node_index + 1
    while i < len(node_list):
      if node_list[i].level <= self.level:
        break
      if node_list[i].level == self.level + 1:
        self.children.append(node_list[i])
      if node_list[i].level > self.level + 1:
        i = node_list[i].Treeify(node_list, i, self)
      i += 1
    return i

  def GetDependencies(self):
    res = sets.Set()
    for child in self.children:
      res.add(child.archive_file)
      res = res.union(child.GetDependencies())
    return res


class DependencyTree(object):

  def IsEndOfTreeLine(self, line):
    return "-----------------------------------------------------------" in line

  def Treeify(self):
    i = 0
    while i < len(self.nodes_):
      i = self.nodes_[i].Treeify(self.nodes_, i, None)

  def ParseFromMaven(self, pom_file):
    maven_output = StringIO.StringIO(subprocess.Popen(
        [sys.argv[1], 'dependency:tree', '-f', pom_file],
        stdout=subprocess.PIPE).communicate()[0])
    line_index = 0
    tree_lines = []
    tree_start = None
    for line in maven_output:
      line = line.rstrip("\n")
      if "maven-dependency-plugin" in line and not tree_start:
        tree_start = line_index + 2
      if tree_start and line_index >= tree_start and self.IsEndOfTreeLine(line):
        break
      if tree_start and line_index >= tree_start:
        tree_lines.append(line)
      line_index += 1
    self.nodes_ = []
    self.node_for_archive_file_ = {}
    for line in tree_lines:
      node = DependencyNode(line)
      self.nodes_.append(node)
      self.node_for_archive_file_[node.archive_file] = node
    self.Treeify()

  def GetDependenciesForArchiveFile(self, archive_file):
    if archive_file in self.node_for_archive_file_:
      return self.node_for_archive_file_[archive_file].GetDependencies()
    return []


def main():
  library_dir = sys.argv[3]
  libraries = glob.glob(os.path.join(library_dir, "*.jar"))
  dep_tree = DependencyTree()
  dep_tree.ParseFromMaven(sys.argv[2])
  for lib in libraries:
    basename = os.path.basename(lib)
    classpath_file = os.path.join(library_dir, basename + ".classpath_")
    with open(classpath_file, 'w') as classpath:
      deps = dep_tree.GetDependenciesForArchiveFile(basename)
      for dep in deps:
        classpath.write(os.path.join(library_dir, dep) + "\n")


if __name__ == "__main__":
  main()

# mvn -f "$pom_file" dependency:tree | "$pcregrep" -o '(?=\+-|\\- ).*'
