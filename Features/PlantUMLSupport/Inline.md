PlantUML inline via code block support
======================================

## Default behaviour

Should show only the *output*:

```{.plantuml}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## Explicit svg output

Should show the *output* as a svg:

```{.plantuml output=html}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## Explicit png output

Should show the *output* as a png:

```{.plantuml output=png}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## Only show the code using the output attribute

Should display the plantuml code instead of its output:

```{.plantuml output=none}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## Only show the code using the code_block attribute

Should display the plantuml code instead of its output:

```{.plantuml code_block=true}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

This version won't even run plantuml.

## Column left / right split

Should display both *code* left of the *output* with default split point (50%):

```{.plantuml .column-split}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## Column left / right split custom split point

Should display both *code* left of the *output* with custom split point (35%):

```{.plantuml column-left-width=35%}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## As code chunk

Should display both the *code* and then the *output*:

```{.plantuml cmd=true}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```


## As code chunk column left / right split

Should display both *code* left of the *output* with default split point (50%):


```{.plantuml cmd=true .column-split}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## As code chunk column left / right split custom split point

Should display both *code* left of the *output* with custom split point (35%):

```{.plantuml cmd=true column-left-width=35%}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## As code chunk, explicitly hiding the code

Should only display the the output (same as by default).

```{.plantuml cmd=true hide=true}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

## As code chunk, explicitly hiding the output

Should display both the *code* and then the *output*:

```{.plantuml cmd=true output=none}
@startuml
Object <|-- ArrayList

Object : equals()
ArrayList : Object[] elementData
ArrayList : size()

@enduml
```

