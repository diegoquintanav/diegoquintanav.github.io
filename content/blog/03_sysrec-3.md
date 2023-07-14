Title: Sistemas recomendadores, parte 3
Date: 2017-11-01 18:01:00 -0600
Modified: 2018-12-03 20:48 -0600
Category: Recommender Systems
Tags: recsys
Slug: recsys-3
Authors: Diego Quintana
Summary: Tercera parte de sistemas recomendadores
Status: draft
Lang: ES

# _previously_

En la [parte 2]({filename}/blog/02_sysrec-2.md) se vieron algunas clasificaciones de _SR_, y mencionamos aquellos basados en _memoria_ y basados en _modelos_. 

Otra clasificación que se mencionó se refiere a _SR_ basados en __contenido__, o _content-based_.

# Sistemas recomendadores basados en contenido

Existen elementos que son cuantificables de manera directa, i.e.

1. Popularidad
2. Género
3. Director
4. Ratings

El filtrado colaborativo permite abordar estos elementos de manera directa. Se vio sin embargo que estos _SR_ sufren de algunos problemas debido a la naturaleza _poco densa_ de los datos en el contexto de recomendación, así como el _new item problem_, entre otros.

Podemos decir también que hay otros elementos que no son cuantificables directamente y dependen de otras cosas, por ejemplo aquellos elementos relacionados al contexto, tales como:

1. Título de una película
1. Descripción de un evento

En teoría, usando análisis de contenido, es posible generar recomendaciones considerando que existen descripciones suficientes. 

Algunos aspectos del análisis de contenido pueden ser

1. Análisis de texto
2. Análisis del perfil de usuario
3. Filtrado de contenido

Este tipo de _SR_ presentan la ventaja de que es más fácil explicar las recomendaciones en función del mismo contenido.

Sin embargo, dado que las recomendaciones dependen del análisis de contenido de las recomendaciones previas, puede ocurrir lo que se conoce como una burbuja de información o _filter bubble_. Esta situación produce que las nuevas recomendaciones terminen siendo muy similares a lo ya consumido. 

Por ejemplo, si me gusta Harry Potter, puede ocurrir que el _SR_ sólo pueda recomendarme libros de Harry Potter y no de la narrativa fantástica en general, lo que dependiendo del caso, puede ser un resultado indeseado.

# ¿Cómo podemos analizar el contenido?

El aspecto más importante de este tipo de _SR_ es su dependencia de la ?_representación_ del contenido. 

De manera más general en otras áreas esto se conoce como _information retrieval_, y tiene que ver en cómo se extrae y representa información de los datos.

En ese sentido, la forma más simple es la de analizar el texto en las descripciones de los ítems que forman parte del dataset.

## Representación vectorial de texto

La primera representación que se puede hacer de un texto es a través de lo que se conoce como [_bag of words_](https://machinelearningmastery.com/gentle-introduction-bag-words-model/), donde las palabras se comparan con un diccionario o _corpus_, y se representan como el número de repeticiones que esa palabra aparece en el texto.

Esto a su vez permite otras representaciones, una es VSM o _Vector space model_, el cual se trata de vectorizar términos en función de su aparición en una **familia** 

Un ejemplo se puede ver en la siguiente imagen, donde la palabra _likes_ se representa como la frecuencia en la que la palabra aparece en tres documentos distintos:

![vsm1]({static}/images/vsm1.png "vsm1")

Usando un procedimiento similar, es posible también representar un **documento** como un vector, donde cada elemento del vector es la frecuencia de cada palabra de un corpus que aparece en el documento.

$$
v = [f_{1},f_{2},...,f_{n}]
$$

donde $f_{i}$ es la frecuencia de cada palabra. Un vector de palabras o diccionario o _corpus_, para el caso del castellano por ejemplo, es de aproximadamente 60000 palabras. 

La ventaja de esta representación es que al tratarse de vectores, estos tienen propiedades geométricas que permiten establecer comparaciones entre ellos.

### Regularización de texto 

La frecuencia de las palabras por sí sola en un documento no ayuda necesariamente a establecer similitudes, por ejemplo es muy posible encontrar muchas veces en un documento las palabras _él, ella, qué, etcétera_, lo que no ayudan mucho. Dos documentos no son necesariamente iguales si tienen relativamente la misma cantidad de veces la palabra _qué_.

Es por esto que se desarrollan métodos de regularización, el primero es normalizar la frecuencia de los términos, a través de lo que se conoce como TF o _term frequency_. En otras palabras, esto significa:

$$
\mbox{TF}(\mbox{palabra},\mbox{documento}) = \frac{\mbox{veces que aparece la palabra en el documento}}{\mbox{cantidad máxima de veces que aparece la palabra en todos los documentos}}
$$

Además, si se considera nuevamente como ejemplo la palabra _qué_, esta no es más importante en un documento si aparece digamos, un 70% de las veces. 
Queremos entonces detectar otras palabras que aparecen con menor frecuencia. Para incorporar esto se usan logaritmos:

$$
\left\{
    \begin{aligned}
    & 1+\log_{10} \mbox{TF}_{p,d} & \mbox{TF}_{p,d} \ge 1\\
    & 0 & \mbox{TF}_{p,d} = 0\\
    \end{aligned}
\right.
$$

Finalmente combinando ambos elementos, es posible obtener una representación estable a través de TF-IDF

$$
\mbox{TF-IDF}{p,d} = \mbox{TF}{p,d} \times \log \frac{N}{n_{p}}
$$

De aquí

- $N$ es la cantidad de documentos del dataset
- $n_{p}$ es la cantidad de documentos donde aparece la palabra
- El valor de $\log(N/n_{p})$ tiende a cero cuando la palabra aparece en muchos documentos (por ejemplo artículos, preposiciones, etc.)

## Representación semántica del contenido y la web semántica

El texto representado como _bag of words_ carece de sentido contextual. El contexto en sí mismo añade una nueva capa al análisis de texto, y entre las formas de incorporarlo se pueden usar _ontologías_.

Al respecto, la idea de una [web semántica](https://en.wikipedia.org/wiki/Semantic_Web) intenta modelar los contenidos de internet a través de estructuras ontológicas estandarizadas llamadas [RDF](https://en.wikipedia.org/wiki/Resource_Description_Framework)

## Métricas de similitud

Como vimos anteriormente, la vectorización de documentos permite operaciones entre vectores, los cuales tienen un sentido geométrico y por lo tanto permiten establecer métricas de distancia entre ellos. 

Las más conocidas ya se han visto y corresponden a:

- Distancia euclidiana
- Distancia coseno

Sin embargo, un _corpus_ en general es de alta dimensionalidad, (60000 palabras para el castellano, por ejemplo) y aquí **la maldición de la dimensionalidad** (_curse of dimensionality_) se presenta nuevamente como un problema. 

Al respecto, podemos normalizar los vectores y obtener mejores resultados con la distancia coseno, y otras métricas diseñadas para este problema como por ejemplo [OKAPI BM25](https://dl.acm.org/citation.cfm?doid=1639714.1639757)

## Manejo de sinónimos

Puede ocurrir que dos palabras son iguales pero tienen distintos significados, lo que complica las comparaciones. Al respecto existen técnicas como

- _Latent semantic Indexing_
- _Latent dirichlet allocation_

## Técnicas de procesamiento adicionales

El análisis de texto presenta otro tipo de problemas, pudiendo encontrarse

- palabras mal escritas
- calidad del texto
- redacción pobre
 
Para esto se pueden usar algunas técnicas auxiliares, como por ejemplo

- Normalización: pasar todo a minúsculas o mayúsculas
- Tokenización: Dividir una oración en unidades o _tokens_. La tokenización depende de cada implementación.
- _Stemming_: Tomar la raíz (_stem_) de las palabras que compartan una raíz semántica (por ejemplo _auto_ en _Automovilismo_ y _Autopista_)
- _Porter_: _Stem_ de las primeras letras que se repiten.
- _Krovetz_: _Stem_, pero asociada a una palabra existente.
- _Lemmatization_: Una variante de _stemming_ que incorpora el análisis morfológico del texto. Ver más información [aquí](https://nlp.stanford.edu/IR-book/html/htmledition/stemming-and-lemmatization-1.html)

## En python

En python existen dos librerías importantes para esto,

- [NLTK](www.nltk.org)
- [Spacy](https://spacy.io)

Aparentemente NLTK tiene más funcionalidades pero su diseño no permite escalar de
la mejor manera. Spacy, al contrario, presenta menos funcionalidades (aunque suficientes) y utiliza _defaults_ aptos para su uso en la industria.

En inglés se dice que una librería es _opinionated_ cuando impone ciertos patrones y procedimientos con base en la experiencia de los creadores de la herramienta. Un ejemplo de esto es _ruby on rails_ o _django_ para desarrollo web.

Esto se podría traducir como un diseño _dogmático_, aunque esta traducción no me gusta del todo.

## A continuación

En la parte 4 se verán
<!-- En la [parte 4]({filename}/blog/04_sysrec-4.md) se verán -->

- Sistemas recomendadores híbridos
- Métricas de calidad en sistemas recomendadores
