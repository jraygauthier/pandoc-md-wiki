.PHONY: \
	all \
	plantuml \
	python

all: \
	plantuml \
	python

plantuml:
	cat "./samples/plantuml/class.plantuml" | skylighting -s plantuml -f ansi -r -a -d ./plantuml.xml

python:
	cat "./samples/python/python.py" | skylighting -s python -f ansi -r -a -d ./python.xml