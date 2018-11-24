Title: Sistemas recomendadores, parte 1
Date: 2017-10-26 18:01:00 -0600
Category: Recommender Systems
Tags: recommender systems; recsys
Slug: recsys-1
Authors: Diego Quintana
Summary: Primera parte de sistemas recomendadores
Status: draft
Modified: 2018-11-24 13:10 -0600

# Acerca de

Me encuentro tomando el módulo de sistemas de recomendación en la PUC
(Ver el programa
[aquí](https://educacionprofesional.ing.uc.cl/?diplomado=diplomado-big-data))
con el profesor [Dennis Parra](http://dparra.sitios.ing.uc.cl/) y como tarea del módulo se hace útil documentar los ejercicios vistos. Cada entrada será un resumen de cada clase, dependiendo cada caso.

## Acerca de esta serie

La idea es de producir al menos un post por clase, tratando de encerrar

- En la [parte 2]({filename}/blog/sysrec-2.md) se revisan las distintas clasificaciones de sistemas recomendadores o SR, con énfasis en el filtrado colaborativo
- En la [parte 3]({filename}/blog/sysrec-3.md) continuamos con esta clasificación, y revisamos los SR basados en contenido y el análisis de texto.
- Todos los SR tienen sus desventajas y debilidades. En la [parte 4]({filename}/blog/sysrec-4.md) revisamos cómo es posible combinar distintos SR para sobreponerse a estas debilidades. También vemos cómo es posible evaluar un SR sobre otro a través de ciertas métricas usadas en clasificación.
- Finalmente en la [parte 5]({filename}/blog/sysrec-5.md) revisamos las máquinas de factorización, un tipo de implementación de máquinas de vectores de soporte que da excelentes resultados en aplicaciones de recomendación y es extensible a otras áreas.

## Sistemas de recomendación

Las recomendaciones son una parte importante de nuestra sociedad.
Seguimos recomendaciones de nuestros padres, amigos y compañeros. Las
seguimos porque de alguna forma, confiamos en la fuente de la
información, confiamos en la experiencia y los gustos de nuestros
círculos más cercanos.

Hasta cierto punto esto es cierto. Nuestros padres y cercanos no saben
de todo, y a veces tenemos que confiar en gente anónima en internet.
Contenidos curados y tratados por gente que tiene un interés particular
sobre algún tema. En esto hay mucho para elegir, y en general la gente
que quiere opinar sobre cosas, digamos:

- [Discos, medios en general](http://www.paniko.cl/)
- [Picadas de comida](https://elpicadista.cl/)
- [Actividades culturales en Santiago](http://estoy.cl/)

Hasta cierto punto podemos confiar en la opinión de anónimos. Igual necesitamos validar de alguna forma las opiniones en internet. Con la cantidad de información disponible en internet,
[_Cualquiera_ puede opinar](http://maddox.xmission.com/).

## Modelando la confianza

Por lo general, y gracias a que a la gente le gusta opinar
sobre cosas ~~sobre todo en internet~~ es que existe mucha información disponible. La forma más elemental de validar algo en internet es, digamos, a través de _ratings_
o _likes_. Lo bueno de esto que una opinión se reduce a un número, y una lista de números tiene algunas propiedades b como el promedio,
varianza, distribución, etc. i.e. herramientas de análisis estadístico.

Los sistemas de recomendación se cuelgan de mucha de esta información
para modelar la confianza a través de recomendaciones. Ejemplos de esto hay por montón.

1.  Netflix colecciona hábitos y gustos de usuarios para crear
    recomendaciones de películas y series
2.  Spotify hace lo mismo, pero recomienda música
3.  Facebook decide qué contenidos y publicidad mostrar en el feed, en base a hábitos de navegación y clicks

En general los sistemas de recomendación permiten lidiar con el **problema de la sobrecarga de información**. Sin estos modelos, lo natural sería que cada uno procesara esta información individualmente. Sería algo así como el equivalente de ir a una biblioteca a leer las contraportadas de libros hasta que alguno parezca valer la pena. _Convengamos que, en algunos casos, esto resulta poco eficiente._

## _Caveat_: Por qué es bueno entender los sistemas de recomendación

En general estos servicios son gratuitos. Nadie paga por usar Facebook. Conocida es la frase _"If you are not paying, then **you** are the product"_

En lo personal creo que esta frase encierra muchas cosas. Primero, es
que acostumbra a los usuarios a consumir ciertos tipos de productos. Hay una serie de externalidades negativas totalmente discutibles, que en general apuntan a _manipular_ la realidad de manera [imperceptible](https://www.theguardian.com/technology/2014/jun/29/facebook-users-emotions-news-feeds). Las consecuencias son de alcances morales y bueno, quedarán para otro post. Segundo es que atrofian ciertas industrias creativas. Reddit tiene un [post (en inglés)](https://www.reddit.com/r/explainlikeimfive/comments/2m3f05/eli5_if_something_is_free_you_are_the_product/) de _Explain like I am five years old_ que resume bien las implicancias de esto.

Dejando de lado la paranoia y el _off-topic_, el filtrado colaborativo permite, según Macnee _et al_

<!-- Todo completar referencia -->

> _Recommender systems aim to help a user or a group of users to select items from a crowded item or information space_

> _(Los sistemas recomendadores buscan asistir a un grupo de usuarios en la selección de ítems desde un conjunto saturado de ítems o de información)_

En general los sistemas de recomendación son una manifestación de
inteligencia colectiva, lo que es bueno. Más gente involucrada en algo es mejor. **Lo importante aquí es entender cómo funcionan estos modelos y eventualmente poder crear modelos propios.** Quizás esto forme parte de la formación general de futuras generaciones. Quién sabe.

## Definición formal del problema

El primer paso es formalizar el problema. Siguiendo la formalización presentada en
[este paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.423.5258&rep=rep1&type=pdf), para un conjunto de usuarios $U$ y un conjunto de items $I$, se
desea obtener un conjunto recomendado de items $R$, tal que

$$R: I \times U \rightarrow R_0$$

Esta transformación $R$ o función de utilidad, se define como la medida de _precisión_ o _propiedad_ de recomendar el item $i \in I$ al usuario $u \in U$, y $R_0$ se asume como subconjunto de $I \times U$ en el cual se conoce el valor de $R$$.

Es así entonces que se tiene, en el contexto de recomendación, la necesidad de

1.  _Estimar o aproximar la función de utilidad $R(i,u)$ sobre aquellos items $i$ sobre los cuales $R$ no se conoce, y_
2.  _Elegir el ítem o el conjunto de ítems tal que maximicen $R$ i.e._

$$\forall u \in U, i = \mbox{argmax } R(i,u) \mbox{, }  i \in I$$

## Métricas de predicción

Una métrica para evaluar la predicción en términos de exactitud es el error. Al respecto existen varias formas de cuantificar el error entre el valor esperado $\hat{r}$ y la predicción $r$, de las cuales se destacan

1.  RMSE, o _root mean square error_ como

$$\sqrt{\frac{\sum_{i=1}^{n}\left(\hat{r}_{ui}-r_{ui}\right)^2}{n}}$$

2.  MSE, o _Mean square error_

$$\frac{\sum_{i=1}^{n}\left(\hat{r}_{ui}-r_{ui}\right)^2}{n}$$

3.  MAE, o _Mean absolute error_

$$\frac{\sum_{i=1}^{n}|\hat{r}_{ui}-r_{ui}|}{n}$$

Estas métricas son de uso frecuente en distintas áreas por lo que no deberían ser novedad.

## Conclusiones

- Los métodos de recomendación buscan lidiar con la sobrecarga de información, entregando recomendaciones de ítems cuando la cantidad de información es muy grande
- Tipos de recomendaciones van desde películas hasta inversiones en la bolsa
- La forma de evaluar un sistema recomendador es a través del error en las predicciones realizadas, al respecto existen varias formas de cuantificar el error

## A continuación

En la [parte 2](10-28-sysrec-2 %}) se verán otras cosas, entre ellas, **tipos de clasificadores.**
