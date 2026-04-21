
(def src-ps "../../purescript")

(def src-css "../../sass-src")

(def src-java "../../src/main/resources")

(def src-harborview "../harborview")

(def cud (os/cwd))

(defn file-exists? [path]
  (let [f (file/open path :r)]
    (if f
      (do (file/close f) true)
      false)))
