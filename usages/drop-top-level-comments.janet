(import ../jipper :as j)

(comment

  (def an-import
    "(import ./analyze :as a)")

  (def a-def
    "(def a 1)")

  (def a-var
    "(var b {:a 1 :b 2})")

  (def a-comment-opener
    "(comment\n")

  (def a-comment-closer
    "  )")

  (def a-defn-
    (string "(defn- f\n"
            "  [x]\n"
            "  (def b 2)\n"
            "  (defn c\n"
            "    [y]\n"
            "    (+ y b))\n"
            "  (c x))"))

  (def a-defmacro-
    (string "(defmacro- median-of-three\n"
            "  [x y z]\n"
            "  ~(if (<= ,x ,y)\n"
            "     (if (<= ,y ,z) ,y (if (<= ,z ,x) ,x ,z))\n"
            "     (if (<= ,z ,y) ,y (if (<= ,x ,z) ,x ,z))))"))

  (def a-main-defn
    (string "(defn main\n"
            "  [& args]\n"
            `  (f 9))`))

  (def src
    (string an-import "\n"
            "\n"
            a-comment-opener "\n"
            "\n"
            a-def "\n"
            "\n"
            a-comment-closer "\n"
            "\n"
            a-defn- "\n"
            "\n"
            a-comment-opener "\n"
            "\n"
            a-defmacro- "\n"
            "\n"
            a-var "\n"
            "\n"
            a-comment-closer "\n"
            "\n"
            a-main-defn))

  (var cur-zloc
    (j/zip-down (j/par src)))

  (def line-comment "# removed comment form")

  (while cur-zloc
    (when (match (j/node cur-zloc) [:tuple _ [:symbol _ "comment"]]
            (set cur-zloc
                 (j/replace cur-zloc [:comment @{} line-comment]))))
    (if-let [right-zloc (j/right cur-zloc)]
      (set cur-zloc right-zloc)
      (break)))

  (j/gen (j/root cur-zloc))
  # =>
  (string an-import "\n"
          "\n"
          line-comment "\n"
          "\n"
          a-defn- "\n"
          "\n"
          line-comment "\n"
          "\n"
          a-main-defn)

  )

