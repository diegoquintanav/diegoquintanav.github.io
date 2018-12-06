Title: Sistemas recomendadores, parte 1
Date: 2017-10-26 18:01:00 -0600
Category: Recommender Systems
Lang: ES
Tags: recsys
Slug: recsys-1
Authors: Diego Quintana
Summary: Primera parte de sistemas recomendadores
Status: published
Modified: 2018-11-24 13:10 -0600

# Por qué esta serie

Me encuentro tomando el módulo de sistemas de recomendación en la PUC
([programa](https://educacionprofesional.ing.uc.cl/?diplomado=diplomado-big-data))
con el profesor [Dennis Parra](http://dparra.sitios.ing.uc.cl/) y como tarea del
 módulo se solicitó crear un post por clase, a modo de resumen.

## Índice

La serie consiste de cinco posts, los que se resumen de la siguiente manera

- En la [parte 2]({filename}/blog/sysrec-2.md) se revisan las distintas
  clasificaciones de sistemas recomendadores o _SR_, con énfasis en el _filtrado colaborativo_
- En la parte 3 continuamos con la clasificación
  de sistemas recomendadores, y revisamos los _SR_ basados en contenido y el análisis de texto.
- Todos los _SR_ tienen sus desventajas y debilidades. En la parte 4
  revisamos cómo es posible combinar distintos _SR_ para sobreponerse a estas
  debilidades. También vemos cómo es posible evaluar un _SR_ y compararlo con
  otro a través de algunas métricas usadas en clasificación.
- Finalmente en la parte 5 revisamos las máquinas
  de factorización, un tipo de implementación de máquinas de vectores de
  soporte que da excelentes resultados en aplicaciones de recomendación y es extensible a otras áreas.

## Sistemas de recomendación

Las recomendaciones son una parte importante de nuestra sociedad.
Seguimos recomendaciones de nuestros padres, amigos y compañeros. Las
seguimos porque de alguna forma, confiamos en ellos, su experiencia y
dado que (generalmente) tenemos una idea de las preferencias en nuestros
círculos, podemos estimar qué tipo de cosas nos pueden recomendar.

Hasta cierto punto esto es cierto. Nuestros padres y cercanos no saben
de todo, y a veces tenemos que acudir al pensamiento colectivo que se encuentra.
en internet. Allí es posible encontrar contenidos curados y tratados por
gente que tiene un interés especial sobre algún tema.

Algunos ejemplos de recomendaciones en internet podrían ser, para Chile y Santiago:

- [Discos, medios en general](http://www.paniko.cl/)
- [Picadas de comida](https://elpicadista.cl/)
- [Actividades culturales en Santiago](http://estoy.cl/)

Sin embargo, tampoco podemos confiar ciegamente en la opinión de anónimos. Tampoco
resulta práctico leer todas las reseñas en internet. Debe existir algún tipo de
_cuantificar_ las recomendaciones, y alguna estrategia para _validarlas_. 
No todas las recomendaciones son _buenas_ desde el punto de vista de cada uno.

## Modelando la confianza

La forma más elemental de validar algo en internet a través de votaciones, _ratings_
o _likes_. Esto nos permite tratar las opiniones de la gente como números, y permite
además extraer promedios, varianzas, _y todas esas cosas_.

El concepto de rating no es nuevo, y algunas de las aplicaciones que se apoyan en esto
son:

1.  [Netflix](http://netflix.com/) recomienda películas
2.  [Spotify](https://mubi.com/) recomienda música
3.  Facebook decide _qué contenidos y publicidad mostrar en el feed_,
     en base a hábitos de navegación y clicks


Los sistemas de recomendación permiten lidiar con el problema de la **sobrecarga de información**.
Sin estos modelos, lo natural sería que cada uno procesara esta información individualmente.

Sería algo así como el equivalente de ir a una biblioteca a leer las
contraportadas de libros hasta que alguno parezca valer la pena. Volviendo a los ejemplos
anteriores,

- En el año 2016, Netflix tenía alrededor de [5500 títulos](http://time.com/4272360/the-number-of-movies-on-netflix-is-dropping-fast/)
  entre películas y series
- Para el año 2013, Spotify tenía alrededor de [20 millones](https://www.digitalmusicnews.com/2013/10/11/songsonspotify/) de canciones.
 de ellas, al menos un 20% no había sido reproducida ni siquiera una vez. [Quizás algo commo esto](https://open.spotify.com/album/0ke5cFySqu1XkaVM4RWUZk)
- En el 2018 Facebook tiene alrededor de [2 billones de usuarios activos](https://www.statista.com/statistics/264810/number-of-monthly-active-facebook-users-worldwide/)


## ¿Por qué es bueno entender los sistemas de recomendación?

En general estos servicios son gratuitos. Nadie paga por usar Facebook.
Conocida es la frase [_"If you are not paying, then **you** are the product"_](https://www.reddit.com/r/explainlikeimfive/comments/2m3f05/eli5_if_something_is_free_you_are_the_product/),
que se traduce como _"Si tú no estás pagando por el producto, es porque tú eres el producto"_

En lo personal creo que esta frase dice muchas cosas.

- Primero, es que un algoritmo de recomendación tiene el poder para dirigir _inadvertidamente_ a ciertos productos.
- Un algoritmo de recomendación puede _manipular_ la realidad de manera [imperceptible](https://www.theguardian.com/technology/2014/jun/29/facebook-users-emotions-news-feeds). Las consecuencias son de tintes morales y bueno, no es el punto revisarlas aquí.
- Un algoritmo de recomendación puede en algunos casos -incluso no intencionalmente- [atrofiar industrias creativas](https://www.dw.com/en/spotify-how-a-swedish-startup-transformed-the-music-industry/a-43230609).

Pero no todo es malo. El filtrado colaborativo permite, entre otras cosas ayudar
 a usuarios a elegir un item (noticia, canción, película, libro) de un conjunto
 masivo de opciones.

Finalmente, los sistemas de recomendación son una manifestación de
inteligencia colectiva, lo que es bueno: Más gente involucrada en algo es mejor. 
Lo importante es entender cómo funcionan estos modelos y así, eventualmente, poder crear modelos propios.

## Definición formal del problema

Siguiendo la formalización presentada en [este paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.423.5258&rep=rep1&type=pdf),
para un conjunto de usuarios $U$ y un conjunto de items $I$, se desea obtener un
 conjunto recomendado de items $R$, tal que

$$R: I \times U \rightarrow R_0$$

Esta transformación $R$ o _función de utilidad_, se define como la medida de
_precisión_ o _propiedad_ de recomendar el item $i \in I$ al usuario $u \in U$,
 y $R_0$ se asume como subconjunto de $I \times U$ en el cual se conoce el valor de $R$$.

Es así entonces que se tiene, en el contexto de recomendación, la necesidad de

1.  _Estimar o aproximar la función de utilidad $R(i,u)$ sobre aquellos items
     $i$ sobre los cuales $R$ no se conoce, y_
2.  _Elegir el ítem o el conjunto de ítems tal que maximicen $R$ i.e._

$$\forall u \in U, i = \mbox{argmax } R(i,u) \mbox{, }  i \in I$$

## Métricas de predicción

Podemos cuantificar el error entre el valor esperado $\hat{r}$ y la predicción $r$, de las cuales se destacan

1.  RMSE, o _root mean square error_ como

$$\sqrt{\frac{\sum_{i=1}^{n}\left(\hat{r}_{ui}-r_{ui}\right)^2}{n}}$$

2.  MSE, o _Mean square error_

$$\frac{\sum_{i=1}^{n}\left(\hat{r}_{ui}-r_{ui}\right)^2}{n}$$

3.  MAE, o _Mean absolute error_

$$\frac{\sum_{i=1}^{n}|\hat{r}_{ui}-r_{ui}|}{n}$$

Estas métricas basadas en el error son de uso frecuente en distintas áreas como
 la estadística y _machine learning_.

## Conclusiones

- Los métodos de recomendación buscan lidiar con la sobrecarga de información,
y reducen el espacio de búsqueda en grupos muy grandes de ítems.
- Algunos tipos de recomendaciones van desde películas hasta inversiones en la bolsa.
- Una forma de evaluar un sistema recomendador es a través del error en las
  predicciones realizadas

## A continuación

En la [parte 2]({filename}/blog/sysrec-2.md) se verán otras cosas, entre ellas, **tipos de clasificadores.**
