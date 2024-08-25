(import jpm)
(import spork) 

(defn calc-md5-sum [f-name]
  (let [tmp-file (file/temp)
        md5-fn (dyn :x-md5)
        p (os/spawn [md5-fn f-name] :p {:out tmp-file})]
    (os/proc-wait p)
    (file/seek tmp-file :set 0)
    (let [buffer (file/read tmp-file :all)
          result (string/slice buffer 0 9)]
        (file/close tmp-file)
        result)))

(defn optionpurchase []
  (let [spago 
        {
          :pkg "optionpurchase"
          :module "OptionPurchaseMain"
          :target "dist/ps-optionpurchase.js"
          :js-file "optionpurchase/dist/ps-optionpurchase.js"
          :js-map-file "../src/main/resources/static/js/optionpurchase/optionpurchase.js.map"
          :js-target "../src/main/resources/static/js/optionpurchase/optionpurchase-%s.js"
        }
        sass 
        {
          :src "../sass-src" 
          :pkg "optionpurchase" 
          :scss-file "optionpurchase.scss"
          :css-file "optionpurchase.css"
          :css-file-2 "optionpurchase/dist/optionpurchase.css"
          :css-map-file "optionpurchase/dist/optionpurchase.css.map"
          :css-map-target"../src/main/resources/static/css/optionpurchase/optionpurchase.css.map"
          :css-target "../src/main/resources/static/css/optionpurchase/optionpurchase-%s.css"
        }]
    { :spago spago 
      :sass sass 
      :tpl "optionpurchase/tpl/optionpurchase.html.tpl"
      :tpl-target "../src/main/resources/templates/optionpurchase/optionpurchases.html"}))

(defn maunaloa []
  (let [spago 
        {
          :pkg "maunaloa"
          :module "Main"
          :target "dist/ps-charts.js"
          :js-file "maunaloa/dist/ps-charts.js"
          :js-map-file "../src/main/resources/static/js/maunaloa/maunaloa.js.map"
          :js-target "../src/main/resources/static/js/maunaloa/ps-charts-%s.js"
        }
        sass 
        {
          :src "../sass-src" 
          :pkg "maunaloa" 
          :scss-file "maunaloa.scss"
          :css-file "maunaloa.css"
          :css-file-2 "maunaloa/dist/maunaloa.css"
          :css-map-file "maunaloa/dist/maunaloa.css.map"
          :css-map-target"../src/main/resources/static/css/maunaloa/maunaloa.css.map"
          :css-target "../src/main/resources/static/css/maunaloa/maunaloa-%s.css"
        }]
    { :spago spago 
      :sass sass 
      :tpl "maunaloa/tpl/charts.html.tpl"
      :tpl-target "../src/main/resources/templates/maunaloa/charts.html"}))

(defn rapanui []
  (let [spago 
          { :pkg "rapanui"
            :module "RapanuiMain"
            :target "dist/rapanui.js"
            :js-file "rapanui/dist/rapanui.js"
            :js-map-file "../src/main/resources/static/js/rapanui/rapanui.js.map"
            :js-target "../src/main/resources/static/js/rapanui/rapanui-%s.js"
            }
        sass
          { :src "../sass-src"
            :pkg "rapanui" 
            :scss-file "rapanui.scss"
            :css-file "rapanui.css"
            :css-file-2 "rapanui/dist/rapanui.css"
            :css-map-file "rapanui/dist/rapanui.css.map"
            :css-map-target"../src/main/resources/static/css/rapanui/rapanui.css.map"
            :css-target "../src/main/resources/static/css/rapanui/rapanui-%s.css"
          }]
    { :spago spago 
      :sass sass 
      :tpl "rapanui/tpl/rapanui.html.tpl"
      :tpl-target "../src/main/resources/templates/rapanui/rapanui.html"}))

(def spago-cmd "/home/rcs/.nvm/versions/node/v20.9.0/bin/spago")
(def sass-cmd "/home/rcs/.nvm/versions/node/v20.9.0/bin/sass")
#(def *exec-spago* @{})

(defn run-spago [cfg]
  (print "Enter run-spago..")
  (let [spago-cfg (cfg :spago)
        pkg (spago-cfg :pkg)
        main-module (spago-cfg :module)
        target (spago-cfg :target)
        md5-file (spago-cfg :js-file)]
    (when (dyn :x-spago)
      (print "EXECUTING SPAGO..")
      (os/execute [spago-cmd "bundle" "--package" pkg "--source-maps" "--module" main-module "--outfile" target]))
    (calc-md5-sum md5-file)))

(defn sass-out-file [cfg]
  (let [sass-cfg (cfg :sass)
        pkg (sass-cfg :pkg)
        css (sass-cfg :css-file)]
    (string/slice (buffer/push-string @"" pkg "/dist/" css))))

(defn run-sass [cfg]
  (print "Enter run-sass..")
  (let [sass-cfg (cfg :sass)
        src (sass-cfg :src)
        pkg (sass-cfg :pkg)
        scss (sass-cfg :scss-file)
        css (sass-cfg :css-file)
        #out-file (string/slice (buffer/push-string @"" pkg "/dist/" css))
        out-file (sass-out-file cfg)
        sass-cmd-input (string/slice (buffer/push-string @"" src "/" pkg "/" scss))]
    (when (dyn :x-sass) 
      (print "EXECUTING SASS..")
      (os/execute [sass-cmd sass-cmd-input out-file]))
    (calc-md5-sum out-file)))

(defn render [cfg spago-md5 sass-md5]
  (print "Enter render..")
  (let [tpl (cfg :tpl)
        f (file/open tpl :r)
        content (string/slice (file/read f :all))]
    (file/close f)
    (let [result (string/format content spago-md5 sass-md5)
          result-file (file/open (cfg :tpl-target) :w)]
      (file/write result-file result)
      (file/close result-file)
      (print result))))

(defn copy-sass-files [cfg sass-md5]
  (print "Enter copy-sass-files..")
  (let [sass-cfg (cfg :sass)
        from-f (sass-cfg :css-file-2)
        to-f (string/format (sass-cfg :css-target) sass-md5)]
    (jpm/shutil/copyfile from-f to-f)))

(defn copy-spago-files [cfg spago-md5]
  (print "Enter copy-spago-files..")
  (let [spago-cfg (cfg :spago)
        from-f (spago-cfg :js-file)
        to-f (string/format (spago-cfg :js-target) spago-md5)]
    (jpm/shutil/copyfile from-f to-f)))

# (defn demo-2 []
#   (print (dyn :x))
#   (pp (curenv)))

(defn run [cfg]
  (let [spago-md5 (run-spago cfg)
        sass-md5 (run-sass cfg)]
    (render cfg spago-md5 sass-md5)
    (copy-spago-files cfg spago-md5)
    (copy-sass-files cfg sass-md5)))

(defn run-optionpurchase []
  (print "Enter run-maunaoa..")
  (run (optionpurchase)))

(defn run-maunaloa []
  (print "Enter run-maunaoa..")
  (run (maunaloa)))

(defn run-rapanui []
  (print "Enter run-rapanui..")
  (run (rapanui)))

(def *x-sass* :x-sass)
(def *x-spago* :x-spago)
(def *x-md5* :x-md5)

(def PROJ {"1" run-rapanui "2" run-maunaloa "3" run-optionpurchase})

(defn main [&] 
  (let 
    [ argx (spork/argparse/argparse "Deploy" 
            "proj"  {:kind :option  :short "p" :help "1: rapanui, 2: maunaloa, 3: optionpurchase" :required true} 
            "md5"   {:kind :option  :short "m" :help "md5 sum function. Linux: md5sum, MacOs: md5. Default: md5sum" :default "md5sum"} 
            "sass"  {:kind :flag    :short "s" :default false :help "Default: false"} 
            "spago" {:kind :flag    :short "g" :default false :help "Default: false"})]
      (if (not= argx nil)
        (let [log (file/open "log" :w)]
          (with-dyns [*out* log
                      *x-sass* (argx "sass")
                      *x-spago* (argx "spago")
                      *x-md5* (argx "md5")]
              (pp argx)
              (let [cmd (PROJ (argx "proj"))]
                (cmd)))
          (file/close log)))))

# (defn xmain [& args] 
#   (if (<= (length args) 1) 
#     (print "args: project (1: rapanui, 2: maunaloa) x-spago (0|1) x-sass (0|1)")
#     (let [log (file/open "log" :w)
#           cmd (PROJ (args 1))]
#       (with-dyns [*out* log
#                   *x-sass* (= (args 3) "1")
#                   *x-spago* (= (args 2) "1")]
#         (cmd))
#       (file/close log))))