
(import ./common :as co)

(defn file-name-for [css-import]
  (let [s (string/split " " css-import)]
    (string/trim (get s 1))))

(defn css-out-file [css-cfg]
  (let [pkg (css-cfg :pkg)
        css (css-cfg :css-file)
        result (string/format "%s/%s/dist/%s" co/src-ps pkg css)]
    result))

(defn css-in-file [css-cfg]
  (let [src (css-cfg :src)
        stem (css-cfg :stem)
        scss (css-cfg :scss-file)
        result (string/format "%s/%s/%s" src stem scss)]
    result))

(defn import-in-file [css-cfg fname]
  (printf "[import-in-file] fname: %q" fname)
  (let [src (css-cfg :src)
        result (string/format "%s/%s.css" src (file-name-for fname))]
    (printf "[import-in-file] result: %s" result)
    result))

(defn local-import-in-file [css-cfg fname]
  (let [src (css-cfg :src)
        stem (css-cfg :stem)]
    (string/format "%s/%s/%s.css" src stem (file-name-for fname))))

(defn import-file [fname out]
  (let [f (file/open fname :r)
          iter (file/lines f)]
    (printf "%s - %q - %q" fname f out)
    (each val iter
      (file/write out val))
    (file/close f)))

(defn run-import-file [line css-cfg f-out]
  (let [cur-in (if (peg/match "local-import" line) 
                  (local-import-in-file css-cfg line)
                  (import-in-file css-cfg line))]
    (import-file cur-in f-out)))

(defn run-css [cfg]
  (let [css-cfg (cfg :css)
        out-file (css-out-file css-cfg)]
    (when (dyn :x-css)
      (let [in-file (css-in-file css-cfg)
            f (file/open in-file)
            f-out (file/open out-file :w)
            iter (file/lines f)]
        (each val iter
          (if (peg/match '(choice "import" "local-import") val)
            (run-import-file val css-cfg f-out)
            (file/write f-out val)))
        (file/close f)
        (file/close f-out)))
    ((dyn :x-md5-cmd) out-file)))


# (run-css (template-app "rapanui" "RapanuiMain" "rapanui" true))
