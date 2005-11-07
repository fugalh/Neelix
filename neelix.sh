export NEELIX_UNINSTALLED='Heck Yes!'
export NEELIX_DEBUG=0
exec ruby -Ilib `pwd`/bin/neelix $*
