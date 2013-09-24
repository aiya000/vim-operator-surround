if exists('g:autoloaded_operator_surround')
    finish
endif
let g:autoloaded_operator_surround = 1

if ! get(g:, 'operator#surround#no_default_blocks', 0)

    function! s:merge(d1, d2)
        for [k, v] in items(a:d2)
            if has_key(a:d1, k)
                call extend(a:d1[k], v)
            else
                let a:d1[k] = v
            endif
        endfor
    endfunction

    let g:operator#surround#blocks = get(g:, 'operator#surround#blocks', {})
    call s:merge( g:operator#surround#blocks,
                \ {
                \   '-' : [
                \       { 'block' : ['(', ')'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['(', ')'] },
                \       { 'block' : ['[', ']'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['[', ']'] },
                \       { 'block' : ['{', '}'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['{', '}'] },
                \       { 'block' : ['<', '>'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['<', '>'] },
                \       { 'block' : ['"', '"'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['"'] },
                \       { 'block' : ["'", "'"], 'motionwise' : ['char', 'line', 'block'], 'keys' : ["'"] },
                \       { 'block' : ['`', '`'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['`'] },
                \       { 'block' : ['( ', ' )'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' (', ' )'] },
                \       { 'block' : ['{ ', ' }'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' {', ' }'] },
                \   ],
                \ } )

    delfunction s:merge
endif


function! s:get_block_or_prefix_match(input, motion)
    for b in g:operator#surround#blocks['-']
        if index(b.motionwise, a:motion) >= 0
            if index(b.keys, a:input) >= 0
                " completely matched
                return b.block
            elseif filter(copy(b.keys), 'v:val =~# "^\\V'.escape(a:input, '"').'"') != []
                " prefix matching
                return 1
            endif
        endif
    endfor
    return 0
endfunction

function! s:get_block_from_input(motion)
    echon 'block : '
    let input = ''
    while 1
        let char = getchar()
        let input .= type(char) == type(0) ? nr2char(char) : char
        let result = s:get_block_or_prefix_match(input, a:motion)
        if type(result) == type([])
            return result
        elseif ! result
            echoerr input . ' is not defined. Please check g:operator#surround#blocks.'
            return 0
        endif
        unlet result
    endwhile
endfunction


function! s:is_empty_region(begin, end)
  return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction

function! s:surround_characters(block_begin, block_end)
    let pos = getpos('.')
    execute 'silent' 'normal!' "`[v`]\<Esc>"
    execute 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", a:block_end, a:block_begin)
    call setpos('.', pos)
endfunction

function! s:append_block(block_pair, motion)
    if a:motion ==# 'char'
        call s:surround_characters(a:block_pair[0], a:block_pair[1])
    else
        throw "Not implemented"
    endif
endfunction


function! operator#surround#append(motion)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let block = s:get_block_from_input(a:motion)
    if type(block) == type(0) && ! block
        return
    endif

    return s:append_block(block, a:motion)
endfunction


function! operator#surround#replace(motion)
    throw "Not implemented"
endfunction


function! operator#surround#delete(motion)
    throw "Not implemented"
endfunction
