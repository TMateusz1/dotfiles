; extends

; Inject JavaScript into:
; - uses: actions/github-script@...
;   with:
;     script: |
;       // JS here

(
  (block_mapping
    ;; Step-level: uses: actions/github-script@...
    (block_mapping_pair
      key: (_) @uses_key
      value: (_) @uses_value
      (#eq? @uses_key "uses")
      (#match? @uses_value "^actions/github-script")
    )

    ;; Step-level: with:
    (block_mapping_pair
      key: (_) @with_key
      value: (block_node
        (block_mapping
          ;; Nested: script: | ...
          (block_mapping_pair
            key: (_) @script_key
            value: (block_node
              (block_scalar) @injection.content
            )
            (#eq? @script_key "script")
          )
        )
      )
      (#eq? @with_key "with")
    )
  )

  (#set! injection.language "javascript")
)
