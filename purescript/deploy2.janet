(import jpm)
(import jpm/shutil :as shutil)
(import spork/argparse :as ap)
(import ./css)

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
      :css css
      :tpl (string/slice (buffer/push-string @"" pkg "/tpl/index.html.tpl"))
      :tpl-target (string/slice (buffer/push-string @"../src/main/resources/templates/" stem "/index.html"))}))

(defn clear-static-files [path]
 (let (fx (os/dir path))
  (each i fx 
    (let (fi (string/slice (buffer/push-string @"" path "/" i)))
      (os/rm fi)))))

(defn copy-css-files [cfg css-md5]
  (print "Enter copy-css-files..")
  (let [css-cfg (cfg :css)
        from-f (css-cfg :css-file-2)
        with-joy (dyn :x-joy)
        to-f (string/format (css-cfg :css-target) css-md5)]
    (if (not with-joy) 
     (clear-static-files (css-cfg :css-static)))
    (jpm/shutil/copyfile from-f to-f)))

(defn run [cfg]
  (let [css-md5 (css/run-css cfg)]
    (pp css-md5)
    (copy-css-files cfg css-md5)))

(defn run-template-app [pkg main stem]
  (printf "Enter %s.." pkg)
  (let [with-joy (dyn :x-joy)]
    (run (template-app pkg main stem with-joy))))

(defn run-rapanui []
  (run-template-app "rapanui" "RapanuiMain" "rapanui"))

(def PROJ {"1" run-rapanui}) 

(defn run [argx]
  (printf "%q" argx)
  (let [os-linux (= (argx "os") "linux")
        md5-cmd (if os-linux md5-linux md5-macos)
        spago-cmd (if os-linux "/usr/local/bin/spago" "/opt/homebrew/bin/spago")]
    (with-dyns [:x-css (argx "css")
                :x-spago (argx "spago")
                :x-elm (argx "elm")
                :x-joy (argx "joy")
                :x-md5-cmd md5-cmd
                :x-spago-cmd spago-cmd]
      (let [cmd (PROJ (argx "proj"))]
        (cmd)))))

(defn main [&]
  (let
    [ argx (ap/argparse "Deploy"
            "proj"  {:kind :option  :short "p" :help "1: rapanui, 2: maunaloa, 3: optionpurchase, 4: options (elm), 5: critters (elm)" :required true}
            "os"    {:kind :option  :short "o" :help "Os: linux, macos. Default: linux" :default "linux"}
            "elm"   {:kind :flag    :short "e" :default false :help "Default: false"}
            "joy"   {:kind :flag    :short "j" :default false :help "Joy backend. Default: false"}
            "css"   {:kind :flag    :short "s" :default false :help "Generate css file. Default: false"}
            "spago" {:kind :flag    :short "g" :default false :help "Generate ps file. Default: false"})]
    (if (not= argx nil)
      (run argx))))
