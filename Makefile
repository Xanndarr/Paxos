# Distributed Algorithms, Coursework 2
# tb1414

.SUFFIXES: .erl .beam

MODULES = system server database replica client acceptor leader commander scout

# BUILD ====================================================

ERLC = erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all: ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

.PHONY: clean
clean:
	rm -f ebin/*

# LOCAL RUN =================================================

SYSTEM = system

L_ERL = erl -noshell -pa ebin -setcookie pass

run: all
	$(L_ERL) -s $(SYSTEM) start
