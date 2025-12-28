

(defn template-app [pkg main stem is-joy-backend]
  (let [css 
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
    {:css css}))

              

(defn file-name-for (css-import)
  (let (s (string/split " " css-import))
    (string/trim (get s 1))))

(defn css-out-file [css-cfg]
  (let [pkg (css-cfg :pkg)
        css (css-cfg :css-file)]
    (string/slice (buffer/push-string @"" pkg "/dist/" css))))

(defn css-in-file [css-cfg]
  (let [src (css-cfg :src)
        pkg (css-cfg :pkg)
        scss (css-cfg :scss-file)]
    (string/slice (buffer/push-string @"" src "/" pkg "/" scss))))

(defn import-in-file (css-cfg fname)
  (let [src (css-cfg :src)]
    (string/slice (buffer/push-string @"" src "/" fname ".scss"))))

(defn import-file (fname out)
  (let (f (file/open fname :r)
        iter (file/lines f))
    (each val iter
      (file/write out val))
      #(pp (string/slice val)))
    (file/close f)))

(defn run-css (cfg)
  (let [css-cfg (cfg :css)
        src (css-cfg :src)
        pkg (css-cfg :pkg)
        scss (css-cfg :scss-file)
        css (css-cfg :css-file)
        out-file (css-out-file css-cfg)
        in-file (css-in-file css-cfg)
        f (file/open in-file)
        f-out (file/open out-file :w)
        iter (file/lines f)]
    (pp out-file)
    (pp in-file)
    (each val iter
      (if (peg/match "import" val)
        (let (s (file-name-for val)
              cur-in (import-in-file css-cfg s))
          (import-file cur-in f-out))
        (file/write f-out val)))
    (file/close f)
    (file/close f-out)))


# (run-css (template-app "rapanui" "RapanuiMain" "rapanui" true))
