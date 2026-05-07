(import jpm/shutil :as shutil)
(import spork/argparse :as ap)
(import ./css)
(import ./common :as co)

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
          { :src co/src-css
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


(defn md5-macos [f-name]
  (with-dyns [:x-md5 "md5"]
    (let [ms (calc-md5-sum f-name)
          sx (string/split " = " ms)
          sx1 (get sx 1)]
      (string/slice sx1 0 8))))

(defn template-app [pkg main stem is-joy-backend]
  (let [spago
          { :pkg pkg
            :module main
            :target (string/slice (buffer/push-string @"" co/src-ps "/" pkg "/dist/" stem ".js"))
            :js-file (string/slice (buffer/push-string @"" co/src-ps "/" pkg "/dist/" stem ".js"))
            :js-static 
              (string/slice (buffer/push-string @"" co/src-java "/static/js/" stem))
            :js-map-file (string/slice (buffer/push-string @"" co/src-ps "/" pkg "/dist/" stem ".js.map"))
            :js-map-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"" co/src-harborview "/public/" stem ".js.map"))
                (string/slice (buffer/push-string @"" co/src-java "/static/js/" stem "/" stem ".js.map")))
            :js-target
              (if is-joy-backend
                (string/slice (buffer/push-string @"" co/src-harborview "/public/" stem ".js"))
                (string/slice (buffer/push-string @"" co/src-java "/static/js/" stem "/" stem "-%s.js")))}
        css 
          { :src co/src-css
            :pkg pkg
            :stem stem
            :scss-file (string/format "%s.scss" stem)
            :css-file (string/format "%s.css" stem)
            :css-file-2 (string/format "%s/%s/dist/%s.css" co/src-ps pkg stem)
            :css-map-file (string/slice (buffer/push-string @"" co/src-ps "/" pkg "/dist/" stem ".css.map"))
            :css-static 
              (string/slice (buffer/push-string @"" co/src-java "/static/css/" stem))
            :css-map-target
              (if is-joy-backend
                (string/format "%s/public/%s.css.map" co/src-harborview stem) 
                (string/slice (buffer/push-string  @"" co/src-java "/static/css/" stem "/" stem ".css.map")))
            :css-target
              (if is-joy-backend
                (string/format "%s/public/%s.css" co/src-harborview stem)
                (string/slice (buffer/push-string @"" co/src-java "/static/css/" stem "/" stem "-%s.css")))}]
    { :spago spago
      :css css
      :tpl (string/slice (buffer/push-string @"" co/src-ps "/" pkg "/tpl/index.html.tpl"))
      :tpl-target (string/slice (buffer/push-string @"" co/src-java "/templates/" stem "/index.html"))}))

(comment clear-static-files [path]
 (let (fx (os/dir path))
   (each i fx 
     (let (fi (string/slice (buffer/push-string @"" path "/" i)))
       (os/rm fi)))))

(defn run-spago [cfg]
  (print "Enter run-spago..")
  (let [spago-cfg (cfg :spago)
        md5-file (spago-cfg :js-file)]
    (when (dyn :x-spago)
      (os/cd co/src-ps)
      (let [pkg (spago-cfg :pkg)
            main-module (spago-cfg :module)
            target (spago-cfg :target)]
        (printf "EXECUTING SPAGO, target: %s" target)
        (os/execute [(dyn :x-spago-cmd) "bundle" "--package" pkg "--source-maps" "--module" main-module "--outfile" target]))
      (os/cd co/cud))
    ((dyn :x-md5-cmd) md5-file)))

(defn copy-spago-files [cfg spago-md5]
  (print "Enter copy-spago-files..")
  (let [spago-cfg (cfg :spago)
        from-f (spago-cfg :js-file)
        to-f (string/format (spago-cfg :js-target) spago-md5)
        from-map-f (spago-cfg :js-map-file)
        to-map-f (spago-cfg :js-map-target)]
    (if (dyn :x-joy) 
      (do
        (shutil/copyfile from-map-f to-map-f)
        (shutil/copyfile from-f to-f))
      (when (not (co/file-exists? to-f))
        (shutil/copyfile from-f to-f)))))

(defn copy-css-files [cfg css-md5]
  (print "Enter copy-css-files..")
  (let [css-cfg (cfg :css)
        from-f (css-cfg :css-file-2)
        with-joy (dyn :x-joy)
        to-f (string/format (css-cfg :css-target) css-md5)]
    (if (dyn :x-joy) 
      (shutil/copyfile from-f to-f)
      (when (not (co/file-exists? to-f))
        (shutil/copyfile from-f to-f)))))

(defn render [cfg spago-md5 css-md5]
  (when (not (dyn :x-joy))
    (print "Enter render..")
    (let [tpl (cfg :tpl)
          f (file/open tpl :r)
          content (string/slice (file/read f :all))]
      (file/close f)
      (print "tpl file: " tpl)
      (let [result (string/format content spago-md5 css-md5)
            result-file (file/open (cfg :tpl-target) :w)]
        (file/write result-file result)
        (file/close result-file)
        (print result)))))

(defn run [cfg]
  (let [css-md5 (css/run-css cfg)
        spago-md5 (run-spago cfg)]
    (printf "css md5: %s" css-md5)
    (copy-spago-files cfg spago-md5)
    (copy-css-files cfg css-md5)
    (render cfg spago-md5 css-md5)))

(defn run-template-app [pkg main stem]
  (printf "Enter %s.." pkg)
  (let [with-joy (dyn :x-joy)]
    (run (template-app pkg main stem with-joy))))

(defn build-app [pkg]
  (printf "BUILD %s.." pkg)
  (os/cd co/src-ps)
  (if (dyn :x-quiet) 
     (os/execute [(dyn :x-spago-cmd) "build" "--quiet" "--package" pkg])
     (os/execute [(dyn :x-spago-cmd) "build" "--package" pkg]))
  (os/cd co/cud))

(defn run-nvim-pre []
  (print "run-nvim-pre"))

(defn run-nvim-post []
  (print "run-nvim-post"))

(defn nvim-pre []
  (when (dyn :x-nvim) 
    (run-nvim-pre)))

(defn nvim-post []
  (when (dyn :x-nvim) 
    (run-nvim-post)))

(defn run-rapanui []
  (nvim-pre)
  (if (dyn :x-build) 
    (build-app "rapanui")
    (run-template-app "rapanui" "RapanuiMain" "rapanui"))
  (nvim-post))

(defn run-maunaloa []
  (nvim-pre)
  (if (dyn :x-build) 
    (build-app "maunaloa")
    (run-template-app "maunaloa" "Main" "maunaloa"))
  (nvim-post))

(defn run-optionpurchase []
  (nvim-pre)
  (if (dyn :x-build) 
    (build-app "optionpurchase")
    (run-template-app "optionpurchase" "OptionPurchaseMain" "optionpurchase"))
  (nvim-post))

(defn run-derivatives []
  (nvim-pre)
  (if (dyn :x-build) 
    (build-app "derivatives")
    (run-template-app "derivatives" "DerivativesMain" "derivatives"))
  (nvim-post))

(def elm-cmd "/usr/local/bin/elm")

(def home-dir "/home/rcs/opt/java/harborview3")
(def ps-dir (string/format "%s/purescript" home-dir))
(def elm-dir (string/format "%s/elm" home-dir))

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

(defn compile-elm []
  (os/cd elm-dir)
  (os/execute [elm-cmd "make" "src/Maunaloa/Options/Main.elm" "--output=elm-options.js"])
  (os/cd ps-dir))

(defn compile-elm-critters []
  (os/cd elm-dir)
  (os/execute [elm-cmd "make" "src/Critters/Main.elm" "--output=elm-critters.js"])
  (os/cd ps-dir))

(defn run-critters []
  (build-app "rigaphoto-app")
  (print "Enter run-options..")
  (when (dyn :x-elm)
    (compile-elm-critters))
  (let [cfg (critters)
          spago-md5 (run-spago cfg)]
    (print "run-critters: " spago-md5)
    (render-critters cfg spago-md5)
    (copy-spago-files cfg spago-md5)))

(defn run-options []
  (build-app "rigaphoto-app")
  (print "Enter run-options..")
  (when (dyn :x-elm)
    (compile-elm))
  (run (options)))


(def PROJ {"1" run-rapanui 
           "2" run-maunaloa 
           "3" run-optionpurchase 
           "4" run-derivatives
           "5" run-options 
           "6" run-critters
           "97" run-nvim-pre 
           "98" run-nvim-post})

(defn proj-item [[index desc is-first]] 
  (if is-first
    (string/format "\n\n\t%d:\t%s" index desc)
    (string/format "%d:\t%s" index desc)))


(defn proj-help []
  (let [projs [[1 "rapanui" true] 
               [2 "maunaloa" false] 
               [3 "optionpurchase" false] 
               [4 "derivatives" false] 
               [5 "options (elm)" false] 
               [6 "critters (elm)" false]] 
        projsx (map proj-item projs)]
    (string/join projsx "\n\t")))

# "proj"  {:kind :option  :short "p" :help "1: rapanui, 2: maunaloa, 3: optionpurchase, 4: derivatives, 5: options (elm), 6: critters (elm), 97: nvim on, 98: nvim off" :required true}

(defn run [argx]
  (printf "%q" argx)
  (let [os-linux (= (argx "os") "linux")
        md5-cmd (if os-linux md5-linux md5-macos)
        spago-cmd (if os-linux "/usr/local/bin/spago" "/usr/local/bin/spago")]
    (with-dyns [:x-css (argx "css")
                :x-spago (argx "spago")
                :x-quiet (argx "quiet")
                :x-elm (argx "elm")
                :x-joy (argx "joy")
                :x-md5-cmd md5-cmd
                :x-spago-cmd spago-cmd
                :x-build (argx "build")
                :x-nvim (argx "nvim")]
      (let [cmd (PROJ (argx "proj"))]
        (cmd)))))

(defn main [&]
  (let
    [ argx (ap/argparse "Deploy"
            "proj"  {:kind :option  :short "p" :help (proj-help) :required true}
            "os"    {:kind :option  :short "o" :help "Os: linux, macos. Default: linux" :default "linux"}
            "elm"   {:kind :flag    :short "e" :default false :help "Default: false"}
            "joy"   {:kind :flag    :short "j" :default false :help "Joy backend. Default: false"}
            "css"   {:kind :flag    :short "s" :default false :help "Generate css file. Default: false"}
            "spago" {:kind :flag    :short "g" :default false :help "Generate ps file. Default: false"}
            "quiet" {:kind :flag    :short "q" :default false :help "Show only errors on build. Default: false"}
            "build" {:kind :flag    :short "b" :default false :help "Build project(s). Default: false"}
            "nvim"  {:kind :flag    :short "n" :default false :help "Nvim. Default: false"})]
    (if (not= argx nil)
      (run argx))))
