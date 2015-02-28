reflex -r '\.(sass|scss)$' -- sh -c 'sassc sass/all.sass static/all.css --style compressed' &
hugo server -D --watch && fg
