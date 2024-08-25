#!/usr/bin/python3

#from cmath import exp
from optparse import OptionParser

from mako.template import Template

import subprocess as proc
from shutil import copyfile
import hashlib

"""
# initializing string
str2hash = "GeeksforGeeks"
 
# encoding GeeksforGeeks using encode()
# then sending to md5()
result = hashlib.md5(str2hash.encode())
 
# printing the equivalent hexadecimal value.
print("The hexadecimal equivalent of hash is : ", end ="")
print(result.hexdigest())
"""


#CSS_HOME = "%s/Purescript/playground/css" % PROJ

#JS_SRC = "%s/photoapp.js" % SRC

#JS_MAP = "photoapp.js.map"

#JS_SRC_MAP = "%s/photoapp.js.map" % SRC

#JS_MIN = "%s/photoapp.min.js" % SRC

#JS_TARGET = "js/%s/photoapp.js" % TARGET


"""
    def render(self):
        tpl = Template(filename="%s/%s/%s" % (TPL_SRC,self.pkg,self.tpl))
        result = tpl.render(psfile=self.md5_file_name)
        dist = "%s/%s/%s" % (TPL_DIST,self.pkg,self.html)
        with(open(dist, "w")) as f:
            f.write(result)


def render_css_(mfn, tpl_name):
    tpl = Template(filename="%s/%s.html.tpl" % (TPL_SRC, tpl_name))
    result = tpl.render(photoapp=mfn)
    dist = "%s/%s.html" % (TPL_DIST,tpl_name)
    with(open(dist, "w")) as f:
        f.write(result)

"""


def PROJ(is_studiop):
    if is_studiop == False:
        return "/home/rcs/opt/java/harborview3"
    else:
        return "/Users/zeus/Projects/PhotoAppMVC"

def TARGET(is_studiop): 
    return "%s/src/main/resources/static/js" % PROJ(is_studiop)

def CSS_HOME(is_studiop):
    return "%s/src/main/resources/static/css" % PROJ(is_studiop)

def TPL_SRC(is_studiop): 
    return "%s/python/tpl" % PROJ(is_studiop)

def TPL_DIST(is_studiop): 
    return "%s/src/main/resources/templates" % PROJ(is_studiop)

PKG     = 1
TPL     = 2
HTML    = 3
MAIN    = 4
JS      = 5
SCSS    = 6
JS_STEM = 8
CSS_TARGET = 9
JS_TARGET = 10
CSS_STEM = 11
SASS = 12

APPS = { 1: {   PKG: "maunaloa", 
                TPL: "maunaloa/charts.html.tpl", 
                HTML: "maunaloa/charts.html", 
                MAIN: "Main",
                CSS_STEM: "maunaloa",
                CSS_TARGET: "maunaloa",
                JS_STEM: "ps-charts",
                JS_TARGET: "maunaloa",
                SASS: "maunaloa" },
        3: {    PKG: "rapanui", 
                TPL: "rapanui/rapanui.html.tpl", 
                HTML: "rapanui/rapanui.html", 
                MAIN: "RapanuiMain",
                CSS_STEM: "rapanui",
                CSS_TARGET: "rapanui",
                JS_STEM: "rapanui",
                JS_TARGET: "rapanui",
                SASS: "rapanui" },
}

def md5_sum(src_file):
    with open(src_file, "r") as fx:
        content = fx.read()
    tmp = hashlib.md5(content.encode())
    result = tmp.hexdigest() # [0:10]
    return result

class Builder:
    def __init__(self,app_id) -> None:
        a = APPS[app_id]
        self.pkg = a[PKG]
        self.main_module = a[MAIN]
        self._md5sum = None

    @property
    def md5sum(self):
        if self._md5sum == None:
            self._md5sum = md5_sum(self.out_file)[0:8]
            print("md5 sum: ", self._md5sum)
        return self._md5sum

    def copy(self):
        print("Copying...")
        print(self.out_file)
        print(self.target)
        copyfile(self.out_file, self.target)

class Sass(Builder):
    def __init__(self,app_id,is_studiop) -> None:
        Builder.__init__(self,app_id)
        a = APPS[app_id]
        self._target = a[CSS_TARGET]
        self.stem = a[CSS_STEM]
        self.out_file = "%s/dist/%s.css" % (self.pkg,self.stem)
        self.sass = a[SASS]
        self.is_studiop = is_studiop

    @property
    def target(self):
        return "%s/%s/%s" % (CSS_HOME(self.is_studiop), self._target, self.md5_file_name)

    @property
    def md5_file_name(self):
        return "%s-%s.css" % (self.stem,self.md5sum)

    def build(self):
        proc.run(["sass", "../sass-src/%s/%s.scss" % (self.sass,self.stem), self.out_file])


class Javascript(Builder):
    def __init__(self,app_id,is_studiop) -> None:
        Builder.__init__(self,app_id)
        a = APPS[app_id]
        self.out_file = "%s/dist/%s.js" % (self.pkg,a[JS_STEM])
        self.map_file = "%s.js.map" % a[JS_STEM]
        self.map_file_src = "%s/dist/%s" % (self.pkg,self.map_file)
        self.out_file_spago = "dist/%s.js" % a[JS_STEM]
        self.stem = a[JS_STEM]
        self._target = a[JS_TARGET]
        self.is_studiop = is_studiop

    @property
    def target(self):
        return "%s/%s/%s" % (TARGET(self.is_studiop), self._target, self.md5_file_name)

    @property
    def md5_file_name(self):
        return "%s-%s.js" % (self.stem,self.md5sum)

    def build(self):
        proc.run(["spago", "bundle", "--package", self.pkg, "--source-maps", "--module", self.main_module, "--outfile", self.out_file_spago])

    def copy(self):
        Builder.copy(self)
        map_target = "%s/%s/%s" % (TARGET(self.is_studiop), self._target, self.map_file)
        print(self.map_file_src)
        print(map_target)
        copyfile(self.map_file_src, map_target)

APP_JS = 1 
APP_SASS = 2
APP_ALL = 3

class Application:
    def __init__(self, app_id, app_variant, is_studiop) -> None:
        self.js = Javascript(app_id, is_studiop) 
        self.sass = Sass(app_id,is_studiop)
        self.variant = app_variant
        a = APPS[app_id]
        self.tpl = a[TPL]
        self.html = a[HTML]
        self.is_studiop = is_studiop

    def build(self):
        if self.variant == 1:
            self.js.build()
        elif self.variant == 2:
            self.sass.build()
        elif self.variant == 3:
            self.js.build()
            self.sass.build()

    def copy(self):
        if self.variant == 1:
            self.js.copy()
        elif self.variant == 2:
            self.sass.copy()
        elif self.variant == 3:
            self.js.copy()
            self.sass.copy()

    def render(self):
        md5_js = self.js.md5_file_name
        md5_css = self.sass.md5_file_name
        tpl = Template(filename="%s/%s" % (TPL_SRC(self.is_studiop), self.tpl))
        result = tpl.render(psname=md5_js,cssname=md5_css)
        dist = "%s/%s" % (TPL_DIST(self.is_studiop),self.html)
        with(open(dist, "w")) as f:
            f.write(result)

    def show_param(self):
        print("****************** %s ******************" % self.sass.pkg)
        print("\ttpl: %s" % self.tpl)
        print("\thtml: %s" % self.html)

    def show_param_js(self):
        self.show_param()
        print("****************** JS ******************")
        print("\tout_file: %s" % self.js.out_file)
        print("\tmap_file: %s" % self.js.map_file)
        print("\tmap_file_src: %s" % self.js.map_file_src)
        print("\tout_file_spago: %s" % self.js.out_file_spago)
        print("\tjs stem: %s" % self.js.stem)
        print("\ttarget: %s" % self.js.target)

    def show_param_css(self):
        self.show_param()
        print("****************** CSS ******************")
        print("\ttarget: %s" % self.sass._target)
        print("\ttarget: %s" % self.sass.target)
        print("\tmain module: %s" % self.sass.main_module)
        print("\tcss stem: %s" % self.sass.stem)
        print("\tsass: %s" % self.sass.sass)
        print("\tout file: %s" % self.sass.out_file)


if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("--css", action="store_true", default=False,
                      help="Css. Default: False")
    parser.add_option("--js", action="store_true", default=False,
                      help="Javascript. Default: False")
    parser.add_option("--build", action="store_true", default=False,
                      help="Build module. Default: False")
    parser.add_option("--copy", action="store_true", default=False,
                      help="Copy. Default: False")
    parser.add_option("--render", action="store_true", default=False,
                      help="Render html templates. Default: False")
    parser.add_option("--all", action="store_true", default=False,
                      help="Build, copy, and render.Default: False")
    parser.add_option("--min", action="store_true", default=False,
                      help="Minify js file. Default: False")
    parser.add_option("--app", dest="app", action="store", type="int",
                      metavar="APP", help="App name: 1-> Maunaloa, 2-> Optionpurchase, 3-> Rapanui")
    parser.add_option("--param", action="store_true", default=False,
                      help="Show Application parameters. Default: False")
    parser.add_option("--studiop", action="store_true", default=False,
                      help="Studio P. Default: False")
    (opts, args) = parser.parse_args()

    cur_var = 0

    if opts.js == True:
        cur_var = 1

    if opts.css == True:
        cur_var += 2

    cur_app = Application(opts.app,cur_var,opts.studiop) 

    if opts.param == True:
        if opts.js == True:
            cur_app.show_param_js()
        if opts.css == True:
            cur_app.show_param_css()

    if opts.build == True:
        print ("--build")
        cur_app.build()

    if opts.copy == True:
        print ("--copy")
        cur_app.copy()

    if opts.render == True:
        print ("--render")
        cur_app.render()

    if opts.all == True:
        print ("--all")
        cur_app.build()
        cur_app.copy()
        cur_app.render()