

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
    (string/slice (buffer/push-string @"" src "/" fname ".css"))))

(defn import-file (fname out)
  (let (f (file/open fname :r)
        iter (file/lines f))
    (each val iter
      (file/write out val))
    (file/close f)))

(defn run-css (cfg)
  (let (css-cfg (cfg :css)
        out-file (css-out-file css-cfg))
    (when (dyn :x-css)
      (let [scss (css-cfg :scss-file)
            in-file (css-in-file css-cfg)
            f (file/open in-file)
            f-out (file/open out-file :w)
            iter (file/lines f)]
        (each val iter
          (if (peg/match "import" val)
            (let (s (file-name-for val)
                  cur-in (import-in-file css-cfg s))
              (import-file cur-in f-out))
            (file/write f-out val)))
        (file/close f)
        (file/close f-out)))
    ((dyn :x-md5-cmd) out-file)))


# (run-css (template-app "rapanui" "RapanuiMain" "rapanui" true))
