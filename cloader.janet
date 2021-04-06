(import sh)
(import spork/path)

(defn- load-cimport
  [c-path args]
  (def c-path (path/abspath c-path))
  (def ext (path/ext c-path))
  (def path-noext
    (string/slice c-path 0 (- (length c-path) (length ext))))
  (def so-path (string path-noext ".so"))
  (def a-path (string path-noext ".a"))
  (def meta-path (string path-noext ".meta.janet"))
  (def base-noext (path/basename path-noext))

  (def should-build
    (if-let [c-stat (os/stat c-path)
             so-stat (os/stat so-path)
             meta-stat (os/stat meta-path)
             a-stat (os/stat a-path)]
      (or (> (c-stat :modified) (so-stat :modified))
          (> (c-stat :modified) (a-stat :modified))
          (> (c-stat :modified) (meta-stat :modified)))
      true))

  (when should-build
    (def start-dir (os/cwd))
    (def td (sh/$<_ mktemp -d))
    (os/cd td)
    (defer (do (os/cd start-dir)
             (sh/$ rm -rf ,td))
      (spit
        "project.janet"
        (string/format
          ```
	  	    (declare-project :name %q)
		      (declare-native :name %q :source @[%q])
	  	    ```
          base-noext base-noext c-path))
      (sh/$ jpm build)
      (sh/$ cp
            (path/join td "build" (string base-noext ".so"))
            ,so-path)
      (sh/$ cp
            (path/join td "build" (string base-noext ".a"))
            ,a-path)
      (sh/$ cp
            (path/join td "build" (string base-noext ".meta.janet"))
            ,meta-path)))

  (native so-path))

# Add the module loader and path tuple to right places
(module/add-paths ".c" :cimport)
(put module/loaders :cimport load-cimport)
