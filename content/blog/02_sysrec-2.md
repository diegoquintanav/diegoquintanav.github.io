Title: Sistemas recomendadores, parte 2
Date: 2017-10-28 20:01:00 -0600
Modified: 2018-11-25 19:15:00 -0600
Category: Recommender Systems
Tags: recsys
Slug: recsys-2
Authors: Diego Quintana
Summary: Segunda parte de sistemas recomendadores
Status: draft
Lang: ES

# _Previously_

En la [parte 1]({filename}/blog/01_sysrec-1.md) se vieron varios aspectos elementales
de los sistemas recomendadores. El concepto del error, Un modelo inicial de una
recomendación, y la necesidad que cubren estos sistemas. 
Mencionamos [este paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.423.5258&rep=rep1&type=pdf) 
con deficiones más rigurosas. La idea ahora es introducir algunos conceptos generales
sobre los tipos de sistemas recomendadores.

Podemos agrupar clasificadores según sus características. [Este paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.702.4429&rep=rep1&type=pdf) presenta algunas directrices, las que serán reflejadas aquí de manera 
menos rigurosa.

# Tipos de recomendadores

## Según el agente que _controla_ el _SR_

El agente se refiere aquí a quién _entrena_ al recomendador. Al respecto se indican

1. Sistemas customizados
2. Sistemas personalizados

El primero es aquel en que _el usuario_ modifica su perfil manualmente en base a sus preferencias, mientras que en el segundo es la implementación del _SR_ la 
que crea y actualiza el perfil para cada usuario, con control explícito mínimo del usuario, e incluso nulo en algunas ocasiones.

## Según la forma que los modelos aprenden

Esta clasificación es más primitiva, y da lugar a

- Sistemas _basados en memoria_
- Sistemas _basados en modelos_

Los primeros son aquellos que **usan datos** i.e clicks, ratings, votos, etc. y establecen una métrica de similitud entre usuarios o ítems. Estas métricas pueden ser de diversos tipos, entre las cuales conviene mencionar

- Similitud coseno
- Correlación de pearson
- Distancia euclidiana

Estas recomendaciones permiten establecer distancias entre personas y/o ítems. Si consideramos una matriz $M$ donde los usuarios son filas y los ítems columnas, los _SR_ basados en memoria establecen similitud entre dos vectores, pudiendo ser

- Entre usuarios (dos o más filas) 
- Entre ítems (dos o más columnas)
- Entre un usuario y un ítem
 
Este tipo de modelos presentan algunos problemas debido a las características de $M$, como por ejemplo

1. El tamaño de $M$ es muy grande: Si la cantidad de datos es masiva, algunos algoritmos que operan sobre todo $M$ se vuelven costosos (Como se verá en KNN más adelante)
2. Densidad de datos: No todos los items o usuarios tienen información i.e. un usuario por lo general no vota en todas las películas de IMDB, sino que sólo en aquellas que le interesan. Esto genera vectores más dispersos o con más elementos vacíos.
3. El problema de la partida en frío o _Cold start_. Cuando un recomendador comienza
no tiene información de ratings, por lo que no puede recomendar nada. El problema
implica entonces el cómo se completa inicialmente esta información. Esto también es válido para nuevos usuarios que no han definido sus preferencias o presentan pocos ratings.

Por el otro lado, los **_SR_ basados en modelos** tratan de completar esta matriz con probabilidades de que un usuario valore positivamente un ítem que no había encontrado antes. Para esto se apoyan en algoritmos de aprendizaje automático o _machine learning_.

### Métricas de similitud

#### Similitud coseno

Si se consideran dos vectores de dimensionalidad $m$, se define la similitud entre ambos a través del cálculo del _coseno_ del ángulo entre ambos vectores. Formalmente, Si consideramos la matriz $M$ de $m$ usuarios y $n$ items, la similitud entre dos elementos está dada por

$$sim(i,j) = \cos (\vec{i},\vec{j}) = \frac{\vec{i} \cdot \vec{j}}{ { \lVert \vec{i} \rVert }_{2} \ast { \lVert \vec{j} \rVert }_{2} }$$

#### Correlación de Pearson

Una métrica de similitud se obtiene a través de la correlación de Pearson. Esta permite aislar los casos donde ocurra _co-validación_ i.e. aquellos casos en que el usuario ha validado ítems $i$ y $j$ (ver imagen, obtenida del paper).

$$sim(i,j) = \frac{ \sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{i})(r_{u,j}-\bar{r}_{j}) }{ \sqrt{\sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{i})^2} \sqrt{\sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{j})^2} }$$

Donde $r_{u,j}$ es el rating del usuario $u$ sobre el ítem $j$ y $\bar{r}_{j}$ es el _rating_ promedio sobre el otro ítem.

![IB-CF1]({static}/images/CF-IB_1.png "IB-CF")

#### Similitud coseno ajustada

Se obtiene incorporando el promedio $\bar{r}_{u}$ de votos de cada usuario en el cálculo de similitud, es decir

$$sim(i,j) = \frac{ \sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{u})(r_{u,j}-\bar{r}_{u}) }{ \sqrt{\sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{u})^2} \sqrt{\sum_{u \in \mathcal{U}}(r_{u,i}-\bar{r}_{u})^2} }$$

De los tres métodos indicados, es esta noción de similitud la que obtiene mejores resultados

![IB-CF2]({static}/images/similarities.png "Similarities comparison")

## Otra propuesta de clasificación

También es posible dividir los _SR_ en cuatro grandes grupos, con base en

- El tipo de datos de entrada que utilizan
- La forma en que construyen perfiles de usuario
- Los métodos algorítmicos usados para producir recomendaciones

Estos son

### Basados en reglas (_Rule based_)

Las reglas son definidas manual y explícitamente en función de los objetivos del 
_SR_, por lo que tienden a ser más rígidos y a depender más de conocimiento 
experto. Esto ocurre mucho en sitios de _e-commerce_, donde los _SR_ reflejan en 
gran medida los intereses de la compañía.

La gran desventaja de estos _SR_ es que dependen de reglas explícitas, y que 
alimentan los perfiles en base a la ingesta manual de intereses del usuario. Todo 
esto incluye un sesgo que entorpece el dinamismo del _SR_ ante nuevos escenarios.

### Basados en contenido (_Content based_)

La principal característica de este _SR_ es que sus recomendaciones se basan en los 
ítems que el usuario ha demostrado interés explícito anteriormente (ejemplo _"Add 
to my wishlist_"). 

Estos recomendadores usan métricas de similitud a través de algoritmos de clasificación, _clustering_ o análisis de texto. Un ejemplo es un recomendador que se basa de las descripciones de productos.

Uno de los contras de estos _SR_ es que dependen de los hábitos y gustos de un 
usuario para poder recomendar nuevos ítems, lo que produce una burbuja. 

Esto se traduce en los siguientes problemas de recomendación

- _¿Cómo puedo recomendar productos nuevos a alguien si no sabe que existen?_
- _¿Cómo decido qué nuevos productos presentarle primero?_ 

En estos casos los ítems más novedosos son la mejor elección.

### Filtrado colaborativo (_User based_)

Apuntan a resolver los problemas presentes en los dos _SR_ anteriores, utilizando 
los datos como clicks y ratings de otros usuarios en la _vecindad_ del usuario 
usando el _SR_.

Tradicionalmente, estos sistemas se dicen _Basados en memoria_ (_Memory based_, un 
término que se considera a veces obsoleto, y que a veces es reemplazado por _User 
based_ o _Item based_), o dicho de otra forma, necesitan tener la información de 
los intereses de _todos_ los usuarios para poder emitir una recomendación. Un 
ejemplo de un algoritmo muy usado en _clustering_ esto es el algoritmo de $k$ 
vecinos cercanos o **KNN** (_K Nearest Neighbors_).

Un problema que presentan estos _SR_ es que operan sobre datasets por lo general 
con poca información. Por ejemplo digamos que un usuario puede haberse manifestado 
sobre dos productos en un conjunto de 1000 productos. El vector de ratings para 
este usuario sería de la forma

$$x_{i} = {0,...,r_{34},r_{35},...,0}$$

donde $r_{34}$ y $r_{35}$ serían dos votaciones distintas de cero. Se tiene 
entonces que existen 998 ceros que no aportan información alguna, lo que se 
transforma en recomendaciones de mala calidad al comienzo de la creación de un 
perfil de usuario. Si consideramos que constantemente se agregan nuevos ítems, este 
dataset se diluye cada vez más.

Otro problema que existen en este tipo de _SR_ es el _new item problem_. Cuando un 
nuevo item es añadido al pool de opciones, no existe en ningún perfil de usuario y 
el _SR_ no puede recomendárselo a nadie.

Finalmente, uno de los pincipales problemas que presentan estos algoritmos es que 
no son escalables. Por ejemplo, para el algoritmo KNN, la formación de _clusters_ obtiene un modelo utilizando todo el conjunto de datos a la vez, lo cual presenta
problemas si pensamos que la generación de nuevos ratings y productos puede ocurrir con mucha frecuencia, incluso a diario.

#### Clasificación de recomendadores basados en filtrado colaborativo

El filtrado colaborativo puede dividirse en dos grandes grupos, dependiendo sobre cuál es la entidad usada para establecer patrones o _clusters_

- filtrado colaborativo basado en usuarios (UB-CF)
- filtrado colaborativo basado en ítems (IB-CF)

Si se considera la matriz $M$ indicada anteriormente, donde las filas son usuarios 
y las columnas ítems, entonces una diferencia fundamental entre estos grupos es el 
eje sobre el cual se establece la similitud, siendo las filas para el primer caso y 
las columnas para el segundo.

La importancia de esto es que cada par en el conjunto a calcular corresponde a 
usuarios distintos. Esto tiene algunas desventajas, como la pérdida de escala entre 
usuarios i.e. no todos los usarios evalúan el mismo ítem de la misma manera, y este 
factor se diluye entre todos los usuarios. Una forma de resolver es con la 
_similitud coseno ajustada_.

Al respecto existen varios tipos de algoritmos basados en el filtrado colaborativo, y dos ejemplos pueden ser

- [Slope One](https://arxiv.org/abs/cs/0702144)
- FunkSVD, [ganador del premio Netflix](http://sifter.org/simon/journal/20061211.html)

##### User Based Collaborative Filtering (UB-CF)

Se puede resumir como

1. La predicción del rating sobre un ítem $i$ mejora mientras más vecinos $k$ de un 
   _pool_ de $n$ elementos de dimensión $d$ se consideren en el cálculo de similitud.
2. La complejidad de calcular la distancia a un ejemplo es de $\mathcal{O}(d)$
3. La complejidad de calcular la distancia a $n$ ejemplos es de $\mathcal{O}(dn)$
4. Una vez calculadas las $n$ distancias, la complejidad de recorrer los $k$ 
   vecinos más cercanos es de $\mathcal{O}(nk)$
5. El tiempo total entonces es de $\mathcal{O}(nd+nk)$, (o $\mathcal{O}(ndk)$ 
   [en función de cómo se recorren los elementos.](https://stats.stackexchange.com/questions/219655/k-nn-computational-complexity)) lo cual vuelve a KNN un algoritmo costoso cuando $n$ es lo suficientemente grande.

Un _SR_ alternativo al _User Based_ (UB-CF) es la del filtrado colaborativo basado en _ítems_, o _Item based collaborative filtering (IB-CF)_

##### Item Based collaborative filtering (IB-CF)

Nacen de la necesidad de generar recomendaciones más rápidas sobre datasets masivos,
para los cuales los algoritmos de tipo UB-CF no escalan bien. 

Estas técnicas analizan primero la matriz de usuarios e ítems $M$ para identificar 
relaciones entre diferentes ítems, y a través de éstas computar calcular de manera 
indirecta nuevas relaciones con los usuarios.

Dicho de otra forma, estos algoritmos exploran las relaciones entre ítems similares,
en vez de realizarla sobre usuarios similares. De esta manera las recomendaciones 
nuevas se logran encontrando ítems similares a otros que el usuario $u$ ha 
calificado positivamente. Dado que las relaciones entre ítems es _relativamente_ 
estática (a diferencia de los gustos de los usuarios, que son más dinámicos), estas 
recomendaciones tienden a ser más estables en el tiempo.

De la misma manera que en el caso de UB-CF, algunas métricas de similitud pueden ser la _correlación entre ítems_, o _similitud coseno_. [Este paper](http://files.grouplens.org/papers/www10_sarwar.pdf) hace una revisión de los métodos indicados, y concluye que este tipo de _SR_ poseen un rendimiento superior, además de proveer mejores recomendaciones que su compañero UB-CF.

### Sistemas híbridos

Los _SR_ basados en contenido y en filtrado colaborativo presentan sus propios problemas. Los sistemas híbridos apuntan a resolver estas limitaciones a través de
combinaciones de otros _SR_

## A continuación

En la [parte 3]({filename}/blog/03_sysrec-3.md) se verán los sistemas de recomendación basados en contenido con mayor detalle.

## Anexo: KNN y la maldición de la dimensionalidad

(o en inglés, _curse of dimensionality_)

### K _Nearest neighbors_ (KNN)

Este algoritmo crea modelos de grupos o _clusters_ de usuarios o ítem que guardan 
relación entre sí de acuerdo a una métrica preestablecida. La idea de KNN en el 
contexto de recomendación es, en términos simples:

> Para un subconjunto de usuarios $\mathcal{U} \in U$, encuentra los ratings para
> un item $i \in I$ sobre los primeros $k$ usuarios (vecinos en este contexto) que 
> sean _objetivamente_ similares a un usuario $u \in \mathcal{U}$\$.

¿Pero cómo se logra establecer similitud _objetivamente_?. Se mide la distancia 
entre dos objetos y vemos si la distancia es lo suficientemente pequeña. Esto se 
puede conseguir generalmente a través de una distancia euclidiana o coseno. [Esta página tiene algunas definiciones sobre esto, y presenta algunos ejemplos usando Python](https://blog.dominodatalab.com/recommender-systems-collaborative-filtering/).

Con una definición _más rigurosa_, decimos que el _rating_ de un 
usuario sobre un item a predecir, es la suma ponderada de los _ratings_ de otros 
$k$ usuarios sobre el mismo ítem que comparten similitud.

$$R(u,i) = \bar{r}_u + \alpha \sum_{j=1}^{k} w(u,j)(r_{j,i}-\bar{r}_j)$$

donde 
- $\alpha$ es un elemento de _regularización_
- $\bar{r}_u$ es el promedio de votos del usuario $u$
- $(r_{j,i}-\bar{r}_j)$ es el voto de cada usuario o vecino sobre el ítem $i$ menos el promedio de sus votos
- $w(u,j)$ es una función que asigna un peso a cada una de estas valoraciones.

## La maldición de la dimensionalidad (o _Curse of dimensionality_)

![curse-of-dimenzionality]({static}/images/curse-of-dimensionality.png "omgsocursed")

(Kudos al [maravilloso ser humano que hizo la imagen.](https://erikbern.com/2015/10/20/nearest-neighbors-and-vector-models-epilogue-curse-of-dimensionality.html))

Básicamente se trata de lo siguiente: Mientras más características tengan los 
vectores usados en la modelación de un ítem o recomendación, la distancia entre dos 
elementos **pierde significancia**.

En términos de un CSV o un _dataframe_, el número de _columnas_ que tiene afecta las medidas entre 
las _filas_. 

Suponiendo un conjunto $X$ de datos $x_i$, cada uno con $d$ dimensiones, se tiene que la **proporción** entre la distancia de cualquier punto hacia el centroide de $X$ (o donde se concentra la mayor cantidad de puntos) y otro punto dentro del mismo espacio se diluye a $0$ _en el infinito_.

Dicho de otra forma, ambas distancias se vuelven _relativamente similares_.

_The curse of dimensionality_ es un tema recurrente en los _SR_, y me limitaré a recorrer algunas lecturas muy completas sobre el tema:

- [_Explain Like I am Five Years Old_](https://stats.stackexchange.com/questions/169156/explain-curse-of-dimensionality-to-a-child) tiene una versión muy simple del problema. En galletas.
  
  > Imagina que debes elegir qué galletas te gustan de un camión de galletas, en 
  > base al sabor. Asumiendo que hay cuatro tipos de sabores (dulce, salado, ácido, 
  > amargo), bastaría con encontrar 4 tipos de galletas diferentes para saber cuál te 
  > gusta más. Si a esto añadimos además una característica de color y asumiendo que 
  > sólo hay cuatro colores, entonces tienes que comer 4x4 tipos de galletas 
  > distintas. Asumiendo que la descripción de galleta se hace cada vez más compleja, y ahora incluye el olor de la galleta. Luego la marca.
  > A medida que las características de la galleta a considerar aumenta, resulta cada vez más difícil saber qué galletas te gustan, y probablemente sufras 
  > un dolor de estómago antes de poder decidir.

- [Este post](https://math.stackexchange.com/questions/346775/confusion-related-to-curse-of-dimensionality-in-k-nearest-neighbor) también es una discusión interesante sobre el tema.
- [Este blog](https://erikbern.com/2015/10/20/nearest-neighbors-and-vector-models-epilogue-curse-of-dimensionality.html) tiene más información aún ~~además de ahorrarme el tiempo de hacer mi propia imagen~~.
- [Este otro post](http://www.visiondummy.com/2014/04/curse-dimensionality-affect-classification/) presenta una explicación más detallada, _que también incluye perritos._

![curse-of-dimenzinality]({static}/images/3Dproblem_separated.png "omgin3D")
