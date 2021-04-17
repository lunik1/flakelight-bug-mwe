# zsh cheatsheet
## grml
### Shortcuts
ESC-e       Edit command                            ESC-h | M-h Open manpage
### Aliases
da          du -sch                                 dir         ls -lSrah
l           ls -l                                   ll          ls -l
la          ls -a                                   lh          ls -hAl
lad         ls dot dirs                             lsa         ls dot files
lsbig       ls 10 biggest files                     lsd         ls dirs
lse         ls empty dirs                           lsl         ls symlinks
lsnew       ls 10 newest files                      lsold       ls 10 oldest files
lssmall     ls 10 smallest files                    lss         ls segid/setuid/sticky
lsw         ls files with world permissions         lsx         ls executables
llog        system log                              tlog        tail (follow) system log
rmcdir      remove current (empty) dir              se          extract archive
top10       top 10 commands                         manzsh      full zsh manual
### Functions
accessed    accessed last n days                    changed     changed last n days
modified    modified last n days                    sll         symlink detail
bk          backup file/dir                         cdt         cd to tmpdir
cl          cd && ls                                mkcd        mkdir && cd
plap        ls in $PATH                             hex         convert # to hex
lcheck      find symbol definition
### abk (C-x .)
C           | wc-l                                  G           |& grep
H           | head                                  T           | tail
N           &>/dev/null                             NN          >/dev/null 2>&1
R           ROT13                                   S           | sort -u
L           | less                                  LL          |& less -r
Hl          | --help |& less -r                     SL          | sort | less
## fzf
C-r         Command history                         C-t         Search files
M-c         cd to                                   `**<TAB>`   Files/dirs
## Personal
### Aliases
s           sudo prev                               pie         sed but perl
bless       bat+less                                brg         batgrep
srsync      rsync over ssh                          pipdate     update pip packages
### Functions
swap        swap files                              pdfopt      shrink pdf
