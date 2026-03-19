(import ../jipper :as j)

(comment

  (def a-def "(def a 1)")

  (def a-zloc (j/zip-down (j/par a-def)))

  (j/node a-zloc)
  # =>
  [:tuple @{:bc 1 :bl 1 :bp 0 :ec 10 :el 1 :ep 9}
    [:symbol @{:bc 2 :bl 1 :bp 1 :ec 5 :el 1 :ep 4} "def"]
    [:whitespace @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} " "]
    [:symbol @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} "a"]
    [:whitespace @{:bc 7 :bl 1 :bp 6 :ec 8 :el 1 :ep 7} " "]
    [:number @{:bc 8 :bl 1 :bp 7 :ec 9 :el 1 :ep 8} "1"]]

  # at top-level syntactically
  (length (j/path a-zloc))
  # =>
  1

  )

# checking whether something is a top-level tuple
(comment

  (def an-import
    "(import ./analyze :as a)")

  (def a-zloc
    (j/zip-down (j/par an-import)))

  (j/node a-zloc)
  # =>
  [:tuple @{:bc 1 :bl 1 :bp 0 :ec 25 :el 1 :ep 24}
    [:symbol @{:bc 2 :bl 1 :bp 1 :ec 8 :el 1 :ep 7} "import"]
    [:whitespace @{:bc 8 :bl 1 :bp 7 :ec 9 :el 1 :ep 8} " "]
    [:symbol @{:bc 9 :bl 1 :bp 8 :ec 18 :el 1 :ep 17} "./analyze"]
    [:whitespace @{:bc 18 :bl 1 :bp 17 :ec 19 :el 1 :ep 18} " "]
    [:keyword @{:bc 19 :bl 1 :bp 18 :ec 22 :el 1 :ep 21} ":as"]
    [:whitespace @{:bc 22 :bl 1 :bp 21 :ec 23 :el 1 :ep 22} " "]
    [:symbol @{:bc 23 :bl 1 :bp 22 :ec 24 :el 1 :ep 23} "a"]]

  (= :code
     (get (j/node (j/up a-zloc)) 0))
  # =>
  true

  # at top-level syntactically
  (length (j/path a-zloc))
  # =>
  1

  (def upscoped
    "(upscope (def a 1))")

  (def u-zloc
    (j/zip-down (j/par upscoped)))

  (j/node u-zloc)
  # =>
  [:tuple @{:bc 1 :bl 1 :bp 0 :ec 20 :el 1 :ep 19}
   [:symbol @{:bc 2 :bl 1 :bp 1 :ec 9 :el 1 :ep 8} "upscope"]
   [:whitespace @{:bc 9 :bl 1 :bp 8 :ec 10 :el 1 :ep 9} " "]
   [:tuple @{:bc 10 :bl 1 :bp 9 :ec 19 :el 1 :ep 18}
    [:symbol @{:bc 11 :bl 1 :bp 10 :ec 14 :el 1 :ep 13} "def"]
    [:whitespace @{:bc 14 :bl 1 :bp 13 :ec 15 :el 1 :ep 14} " "]
    [:symbol @{:bc 15 :bl 1 :bp 14 :ec 16 :el 1 :ep 15} "a"]
    [:whitespace @{:bc 16 :bl 1 :bp 15 :ec 17 :el 1 :ep 16} " "]
    [:number @{:bc 17 :bl 1 :bp 16 :ec 18 :el 1 :ep 17} "1"]]]

  (def def-zloc
    (-> u-zloc
        j/down
        j/right-skip-wsc))

  (j/node def-zloc)
  # =>
  [:tuple @{:bc 10 :bl 1 :bp 9 :ec 19 :el 1 :ep 18}
   [:symbol @{:bc 11 :bl 1 :bp 10 :ec 14 :el 1 :ep 13} "def"]
   [:whitespace @{:bc 14 :bl 1 :bp 13 :ec 15 :el 1 :ep 14} " "]
   [:symbol @{:bc 15 :bl 1 :bp 14 :ec 16 :el 1 :ep 15} "a"]
   [:whitespace @{:bc 16 :bl 1 :bp 15 :ec 17 :el 1 :ep 16} " "]
   [:number @{:bc 17 :bl 1 :bp 16 :ec 18 :el 1 :ep 17} "1"]]

  # not at top-level syntactically
  (length (j/path def-zloc))
  # =>
  2

  )

# checking if something is effectively a top-level tuple
(comment

  (def a-def
    "(def a 1)")

  (def a-comment-opener
    "(comment\n")

  (def a-comment-closer
    "  )")

  (def a-comment-form
    (string a-comment-opener
            "\n"
            a-def "\n"
            "\n"
            a-comment-closer))

  (def b-zloc
    (-> (j/zip-down (j/par a-comment-form))
        (j/search-after |(match (j/node $) [:tuple] $))))

  (j/node b-zloc)
  # =>
  [:tuple @{:bc 1 :bl 3 :bp 10 :ec 10 :el 3 :ep 19}
   [:symbol @{:bc 2 :bl 3 :bp 11 :ec 5 :el 3 :ep 14} "def"]
   [:whitespace @{:bc 5 :bl 3 :bp 14 :ec 6 :el 3 :ep 15} " "]
   [:symbol @{:bc 6 :bl 3 :bp 15 :ec 7 :el 3 :ep 16} "a"]
   [:whitespace @{:bc 7 :bl 3 :bp 16 :ec 8 :el 3 :ep 17} " "]
   [:number @{:bc 8 :bl 3 :bp 17 :ec 9 :el 3 :ep 18} "1"]]

  (def c-zloc
    (j/up b-zloc))

  (when-let [c-node (j/node c-zloc)
             head-zloc (j/down c-zloc)
             head-node (j/node head-zloc)]
    (and (= :tuple (get c-node 0))
         (or # XXX: this part is not quite right if there is some
             #      non-whitespace / non-comment thing that occurs
             #      as the "head" element instead
             (and (= :symbol (get head-node 0))
                  (= "comment" (get head-node 2)))
             (when-let [non-wsc-node (j/right-skip-wsc head-node)]
               (and (= :symbol (get head-node 0))
                    (= "comment" (get head-node 2)))))))
  # =>
  true

  (= :code
     (get (j/node (j/up (j/up b-zloc))) 0))
  # =>
  true

  )

