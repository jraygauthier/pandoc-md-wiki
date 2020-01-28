.PHONY: \
	all \
	plantuml \
	python

all: \
	plantuml \
	python


# Nice clear theme. Distinguish built-in color.
SL_STYLE := kate
# Nice dark theme. Distinguish built-in color.
# SL_STYLE := breeze-dark
# Nice dark theme. Distinguish operator color.
SL_STYLE := pygments
# SL_STYLE := espresso
# SL_STYLE := tango
# SL_STYLE := haddock
# SL_STYLE := monochrome
# zenburn -> Does not exists

SL_PLANTUML_ANSI_ARGS := -S $(SL_STYLE) -s plantuml -f ansi -r -a -d ./plantuml.xml

SL_PLANTUML_NATIVE_ARGS := -s plantuml -f native -r -a -d ./plantuml.xml

plantuml-class:
	cat "./samples/plantuml/class.plantuml" | skylighting $(SL_PLANTUML_ANSI_ARGS)

plantuml-class-native:
	cat "./samples/plantuml/class.plantuml" | skylighting $(SL_PLANTUML_NATIVE_ARGS)

plantuml-activity:
	cat "./samples/plantuml/activity.plantuml" | skylighting $(SL_PLANTUML_ANSI_ARGS)

plantuml-activity-native:
	cat "./samples/plantuml/activity.plantuml" | skylighting $(SL_PLANTUML_NATIVE_ARGS)

plantuml-sequence:
	cat "./samples/plantuml/sequence.plantuml" | skylighting $(SL_PLANTUML_ANSI_ARGS)

plantuml-sequence-native:
	cat "./samples/plantuml/sequence.plantuml" | skylighting $(SL_PLANTUML_NATIVE_ARGS)

plantuml-state:
	cat "./samples/plantuml/state.plantuml" | skylighting $(SL_PLANTUML_ANSI_ARGS)

plantuml-timing:
	cat "./samples/plantuml/timing.plantuml" | skylighting $(SL_PLANTUML_ANSI_ARGS)

plantuml-timing-native:
	cat "./samples/plantuml/timing.plantuml" | skylighting $(SL_PLANTUML_NATIVE_ARGS)

plantuml: \
	plantuml-class \
	plantuml-activity \
	plantuml-sequence \
	plantuml-state \
	plantuml-timing \

python:
	cat "./samples/python/python.py" | skylighting -s python -f ansi -r -a -d ./python.xml