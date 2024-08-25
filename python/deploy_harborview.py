#!/usr/bin/python3

from optparse import OptionParser

from mako.template import Template

import subprocess as proc
from shutil import copyfile
import hashlib

def md5_sum(src_file):
    with open(src_file, "r") as fx:
        content = fx.read()
    tmp = hashlib.md5(content.encode())
    result = tmp.hexdigest() # [0:10]
    return result

class Spago:
  def __init__(self, pkg, module, target, js_file, js_map_file, js_target):
    self.pkg = pkg
    self.module = module 
    self.target = target 
    self.js_file = js_file 
    self.js_map_file = js_map_file 
    self.js_target = js_target 
    self.__md5 = None

  def build(self):
    # (list "spago" "bundle" "--package" pkg "--source-maps" "--module" main-module "--outfile" target)))
    print("I am Spago, and building")
    proc.run(["spago", "bundle", "--package", self.pkg, "--source-maps", "--module", self.module, "--outfile", self.target])

  @property
  def md5(self):
    if self.__md5 == None:
      self.__md5 = md5_sum(self.js_file)[0:8]
    return self.__md5


class Sass:
  def __init__(self, src, pkg, scss_file, css_file, css_file_2, css_map_file, css_map_target, css_target):
    self.src = src
    self.pkg = pkg
    self.scss_file = scss_file
    self.css_file = css_file
    self.css_file_2 = css_file_2
    self.css_map_file = css_map_file
    self.css_map_target = css_map_target
    self.css_target = css_target
    self.__md5 = None

  @property
  def out_file(self):
    return "%s/dist/%s" % (self.pkg,self.css_file)

  @property
  def md5(self):
    if self.__md5 == None:
      self.__md5 = md5_sum(self.out_file)[0:8]
    return self.__md5

  def build(self):
    print("I am Sass, and building")
    #out_file = "%s/dist/%s" % (self.pkg,self.css_file)
    proc.run(["sass", "../sass-src/%s/%s" % (self.pkg,self.scss_file), self.out_file])

  def copy(self):
    tgt = self.css_target % self.md5
    print("%s" % tgt)

class Builder:
  def build(self):
    print("I am building")
    print(self.opts)
    if self.opts.css == True:
      self.sass.build()
    if self.opts.js == True:
      # self.spago.build()
      pass
    print (self.spago.md5)
    self.sass.copy()

class Maunaloa(Builder):
  def __init__(self,opts):
    self.spago = None
    self.sass = None
    self.opts = opts

class Rapanui(Builder):
  def __init__(self,opts):
    self.spago = Spago("rapanui", 
                        "RapanuiMain", 
                        "dist/rapanui.js",
                        "rapanui/dist/rapanui.js",
                        "../src/main/resources/static/js/rapanui/rapanui.js.map",
                        "../src/main/resources/static/js/rapanui/rapanui-%s.js")
    self.sass = Sass("../sass-src",
                      "rapanui",
                      "rapanui.scss",
                      "rapanui.css",
                      "rapanui/dist/rapanui.css",
                      "rapanui/dist/rapanui.css.map",
                      "../src/main/resources/static/css/rapanui/rapanui.css.map",
                      "../src/main/resources/static/css/rapanui/rapanui-%s.css")
    self.opts = opts


APPS = {
  1: Maunaloa,
  3: Rapanui
}

def get_app(opts):
  if opts.app not in  APPS:
    raise Exception("No such app_index: %d" % opts.app)
  return APPS[opts.app](opts)

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("--css", action="store_true", default=False,
                      help="Css. Default: False")
    parser.add_option("--js", action="store_true", default=False,
                      help="Javascript. Default: False")
    parser.add_option("--app", dest="app", action="store", type="int",
                      metavar="APP", help="App name: 1-> Maunaloa, 2-> Optionpurchase, 3-> Rapanui")
    parser.add_option("--build", action="store_true", default=False,
                      help="Build module. Default: False")

    (opts, args) = parser.parse_args()

    try:
      cur_app = get_app(opts)
      print(cur_app)
    except Exception as e:
      print (e)
      exit(1)
      

    if opts.build == True:
      print ("--build")
      cur_app.build() 
