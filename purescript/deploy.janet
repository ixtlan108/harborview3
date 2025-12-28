(import jpm)
(import jpm/shutil :as shutil)
(import spork/argparse :as ap)
#(import spork/argparse :refer '[argparse])

(defn calc-md5-sum [f-name]
  (let [tmp-file (file/temp)
        md5-fn (dyn :x-md5)
        p (os/spawn [md5-fn f-name] :p {:out tmp-file})]
    (os/proc-wait p)
    (file/seek tmp-file :set 0)
    (let [buffer (file/read tmp-file :all)
          result (string/slice buffer)]
        (file/close tmp-file)
        result)))

(defn md5-linux [f-name]
  (with-dyns [:x-md5 "md5sum"]
    (let [ms (calc-md5-sum f-name)]
      (string/slice ms 0 8))))

# (def m5s "MD5 (/Users/zeus/Projects/PhotoAppMVC/cl/deploy-ps/t/resources/rigaphoto-482af713.css) = 482af7137144614ed3535474843429f3")

(defn md5-macos [f-name]
  (with-dyns [:x-md5 "md5"]
    (let [ms (calc-md5-sum f-name)
          sx (string/split " = " ms)
          sx1 (get sx 1)]
      (string/slice sx1 0 8))))



# (def spago-cmd "/home/rcs/.nvm/versions/node/v20.9.0/bin/spago")
# (def spago-cmd "/usr/local/bin/spago")
# (def sass-cmd "/home/rcs/.nvm/versions/node/v20.9.0/bin/sass")
# (def sass-cmd "/usr/bin/sass")

(def elm-cmd "/usr/local/bin/elm")

(def home-dir "/home/rcs/opt/java/harborview3")
(def ps-dir (string/format "%s/purescript" home-dir))
(def elm-dir (string/format "%s/elm" home-dir))



(defn run-spago [cfg]
  (print "Enter run-spago..")
  (let [spago-cfg (cfg :spago)
        md5-file (spago-cfg :js-file)]
    (when (dyn :x-spago)
      (let [pkg (spago-cfg :pkg)
            main-module (spago-cfg :module)
            target (spago-cfg :target)]
        (print "EXECUTING SPAGO..")
        (os/execute [(dyn :x-spago-cmd) "bundle" "--package" pkg "--source-maps" "--module" main-module "--outfile" target])))
    ((dyn :x-md5-cmd) md5-file)))

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
        out-file (sass-out-file cfg)
        sass-cmd-input (string/slice (buffer/push-string @"" src "/" pkg "/" scss))]
    (when (dyn :x-sass)
      (print "EXECUTING SASS..")
      (os/execute [(dyn :x-sass-cmd) sass-cmd-input out-file]))
    ((dyn :x-md5-cmd) out-file)))

(defn compile-elm []
  (os/cd elm-dir)
  (os/execute [elm-cmd "make" "src/Maunaloa/Options/Main.elm" "--output=elm-options.js"])
  (os/cd ps-dir))

(defn compile-elm-critters []
  (os/cd elm-dir)
  (os/execute [elm-cmd "make" "src/Critters/Main.elm" "--output=elm-critters.js"])
  (os/cd ps-dir))

(defn render [cfg spago-md5 sass-md5]
  (let [is-joy (dyn :x-joy)]
    (when (not is-joy)
      (print "Enter render..")
      (let [tpl (cfg :tpl)
            f (file/open tpl :r)
            content (string/slice (file/read f :all))]
        (file/close f)
        (print "tpl file: " tpl)
        (let [result (string/format content spago-md5 sass-md5)
              result-file (file/open (cfg :tpl-target) :w)]
          (file/write result-file result)
          (file/close result-file)
          (print result))))))

(defn render-critters [cfg spago-md5]
  (print "Enter render..")
  (print (cfg :tpl))
  (let [tpl (cfg :tpl)
        f (file/open tpl :r)
        content (string/slice (file/read f :all))]
    (file/close f)
    (let [result (string/format content spago-md5)
          result-file (file/open (cfg :tpl-target) :w)]
      (file/write result-file result)
      (file/close result-file)
      (print result))))

(defn clear-static-files [path]
 (let (fx (os/dir path))
  (each i fx 
    (let (fi (string/slice (buffer/push-string @"" path "/" i)))
      (os/rm fi)))))

(defn copy-sass-files [cfg sass-md5]
  (print "Enter copy-sass-files..")
  (let [sass-cfg (cfg :sass)
        from-f (sass-cfg :css-file-2)
        with-joy (dyn :x-joy)
        to-f (string/format (sass-cfg :css-target) sass-md5)]
    (if (not with-joy) 
     (clear-static-files (sass-cfg :css-static)))
    (jpm/shutil/copyfile from-f to-f)))

(defn copy-spago-files [cfg spago-md5]
  (print "Enter copy-spago-files..")
  (let [spago-cfg (cfg :spago)
        from-f (spago-cfg :js-file)
        with-joy (dyn :x-joy)
        to-f (string/format (spago-cfg :js-target) spago-md5)
        from-map-f (spago-cfg :js-map-file)
        to-map-f (spago-cfg :js-map-target)]
    (if (not with-joy) 
     (clear-static-files (spago-cfg :js-static)))
    (shutil/copyfile from-f to-f)
    (shutil/copyfile from-map-f to-map-f)))

(defn run [cfg]
  (let [spago-md5 (run-spago cfg)
        sass-md5 (run-sass cfg)]
    (render cfg spago-md5 sass-md5)
    (copy-spago-files cfg spago-md5)
    (copy-sass-files cfg sass-md5)))

(defn critters []
  (let [spago
          {
            :js-file "/home/rcs/opt/java/harborview3/elm/elm-critters.js"
            :js-target "../src/main/resources/static/js/critters/elm-critters-%s.js"}]
            
    { :spago spago
      :sass nil
      :tpl "critter/tpl/overlook.html.tpl"
      :tpl-target "../src/main/resources/templates/critter/overlook.html"}))

(defn options []
  (let [spago
          {
            :js-file "/home/rcs/opt/java/harborview3/elm/elm-options.js"
            :js-target "../src/main/resources/static/js/maunaloa/elm-options-%s.js"}
            
        sass
          { :src "../sass-src"
            :pkg "options"
            :scss-file "options.scss"
            :css-file "options.css"
            :css-file-2 "options/dist/options.css"
            :css-map-file "options/dist/options.css.map"
            :css-map-target"../src/main/resources/static/css/maunaloa/options.css.map"
            :css-target "../src/main/resources/static/css/maunaloa/options-%s.css"}]
          
    { :spago spago
      :sass sass
      :tpl "options/tpl/options.html.tpl"
      :tpl-target "../src/main/resources/templates/maunaloa/options.html"}))

(defn template-app [pkg main stem is-joy-backend]
  (let [spago
          { :pkg pkg
            :module main
            :target (string/slice (buffer/push-string @"dist/" stem ".js"))
            :js-file (string/slice (buffer/push-string @"" pkg "/dist/" stem ".js"))
            :js-static 
              (string/slice (buffer/push-string @"../src/main/resources/static/js/" stem))
            :js-map-file (string/slice (buffer/push-string @"" pkg "/dist/" stem ".js.map"))
            :js-map-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".js.map"))
                (string/slice (buffer/push-string @"../src/main/resources/static/js/" stem "/" stem ".js.map")))
            :js-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".js"))
                (string/slice (buffer/push-string @"../src/main/resources/static/js/" stem "/" stem "-%s.js")))}
        sass
          { :src "../sass-src"
            :pkg stem
            :scss-file (string/slice (buffer/push-string @"" stem ".scss"))
            :css-file (string/slice (buffer/push-string @"" stem ".css"))
            :css-file-2 (string/slice (buffer/push-string @"" pkg "/dist/" stem ".css"))
            :css-map-file (string/slice (buffer/push-string @"" pkg "/dist/" stem ".css.map"))
            :css-static 
              (string/slice (buffer/push-string @"../src/main/resources/static/css/" stem))
            :css-map-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".css.map"))
                (string/slice (buffer/push-string  @"../src/main/resources/static/css/" stem "/" stem ".css.map")))
            :css-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".css"))
                (string/slice (buffer/push-string @"../src/main/resources/static/css/" stem "/" stem "-%s.css")))}
        css 
          { :src "../sass-src"
            :pkg stem
            :scss-file (string/slice (buffer/push-string @"" stem ".scss"))
            :css-file (string/slice (buffer/push-string @"" stem ".css"))
            :css-file-2 (string/slice (buffer/push-string @"" pkg "/dist/" stem ".css"))
            :css-map-file (string/slice (buffer/push-string @"" pkg "/dist/" stem ".css.map"))
            :css-static 
              (string/slice (buffer/push-string @"../src/main/resources/static/css/" stem))
            :css-map-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".css.map"))
                (string/slice (buffer/push-string  @"../src/main/resources/static/css/" stem "/" stem ".css.map")))
            :css-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"../janet/harborview/public/" stem ".css"))
                (string/slice (buffer/push-string @"../src/main/resources/static/css/" stem "/" stem "-%s.css")))}]
    { :spago spago
      :sass sass
      :css css
      :tpl (string/slice (buffer/push-string @"" pkg "/tpl/index.html.tpl"))
      :tpl-target (string/slice (buffer/push-string @"../src/main/resources/templates/" stem "/index.html"))}))


(defn run-template-app [pkg main stem]
  (printf "Enter %s.." pkg)
  (let [with-joy (dyn :x-joy)]
    (run (template-app pkg main stem with-joy))))

(defn run-rapanui []
  (run-template-app "rapanui" "RapanuiMain" "rapanui"))

(defn run-maunaloa []
  (run-template-app "maunaloa" "Main" "maunaloa"))

(defn run-optionpurchase[]
  (run-template-app "optionpurchase" "OptionPurchaseMain" "optionpurchase"))

(defn run-critters []
 (print "Enter run-options..")
 (when (dyn :x-elm)
   (compile-elm-critters))
 (let [cfg (critters)
         spago-md5 (run-spago cfg)]
     (print "run-critters: " spago-md5)
     (render-critters cfg spago-md5)
     (copy-spago-files cfg spago-md5)))

(defn run-options []
  (print "Enter run-options..")
  (when (dyn :x-elm)
    (compile-elm))
  (run (options)))

(def PROJ {"1" run-rapanui 
           "2" run-maunaloa 
           "3" run-optionpurchase 
           "4" run-options 
           "5" run-critters})

(defn run [argx]
  (printf "%q" argx)
  (let [os-linux (= (argx "os") "linux")
        md5-cmd (if os-linux md5-linux md5-macos)
        sass-cmd (if os-linux "/usr/local/bin/sass" "/opt/homebrew/bin/sass")
        spago-cmd (if os-linux "/usr/local/bin/spago" "/opt/homebrew/bin/spago")]
    (with-dyns [:x-sass (argx "sass")
                :x-spago (argx "spago")
                :x-elm (argx "elm")
                :x-joy (argx "joy")
                :x-md5-cmd md5-cmd
                :x-sass-cmd sass-cmd
                :x-spago-cmd spago-cmd]
      (let [cmd (PROJ (argx "proj"))]
        (cmd)))))


(defn main [&]
  (let
    [ argx (ap/argparse "Deploy"
            "proj"  {:kind :option  :short "p" :help "1: rapanui, 2: maunaloa, 3: optionpurchase, 4: options (elm), 5: critters (elm)" :required true}
            "os"    {:kind :option  :short "o" :help "Os: linux, macos. Default: linux" :default "linux"}
            "log"   {:kind :flag    :short "l" :default false :help "If set, will write to log. Default: false"}
            "elm"   {:kind :flag    :short "e" :default false :help "Default: false"}
            "joy"   {:kind :flag    :short "j" :default false :help "Joy backend. Default: false"}
            "sass"  {:kind :flag    :short "s" :default false :help "Default: false"}
            "spago" {:kind :flag    :short "g" :default false :help "Default: false"})]
    (if (not= argx nil)
      (if (= (argx "log") true)
        (let [log (file/open "log" :w)]
          (with-dyns [*out* log]
            (run argx))
          (file/close log))
        (run argx)))))
