Title: Sistemas recomendadores, parte 5
Lang: ES
Date: 2017-11-15 18:01:00 -0600
Category: Recommender Systems
Tags: recsys
Slug: recsys-5
Authors: Diego Quintana
Summary: Quinta parte de sistemas recomendadores
Status: draft

<!-- entry 5, clase al 15.11 -->

# _Previously_

En el [post anterior]({filename}/blog/04_sysrec-4.md) se hizo una revisión de los Sistemas recomendadores híbridos y se revisaron algunas métricas usadas en su evaluación. Lo que queda como última parte de esta serie, es hablar sobre Máquinas de factorización. Las máquinas de factorización pueden verse como máquinas de vectores de soporte (SVM, _support vector machines_), utilizando con un kernel polinomial. 

Pero antes, ¿Qué es una máquina de vectores de soporte?

## Máquinas de vectores de soporte

Es uno de los clasificadores clásicos usados en machine learning. Dado que no es la idea profundizar en este algoritmo, se podría resumir en lo siguiente

Dadas dos clases **A** y **B**, una SVM es un clasificador $\mathcal{C}$ que encuentra un plano de decisión $h$, tal que la distancia de tal plano a dos vectores llamados de soporte sea máxima. Estos vectores de soporte son obtenidos a través de un proceso de optimización, y los planos de decisión pueden extenderse a otras superficies más complejas a través de lo que se conoce como _the kernel trick_ (Explicado muy bien [aquí](http://www.eric-kim.net/eric-kim-net/posts/1/kernel_trick.html)).

![svm1](https://ml.berkeley.edu/blog/assets/tutorials/2/image_2.png)

Un _kernel_ resuelve un problema donde para algún conjunto de datos, no existe un plano de decisión $h$ o en otras palabras las clases no son separables. El kernel actúa como una transformación que en ciertas condiciones, permite operar sobre una representación de $\mathcal{C}$ donde sí existe la separación $h$.

![kernel1]({static}/images/data_2d_to_3d.png)

Un kernel se escribe matemáticamente como

$$
K: \mathbb{R}^M \times \mathbb{R}^M \rightarrow \mathbb{R}^N
$$

Tal que

$$
K(\vec{x}_{i},\vec{x}_{j}) = \langle { \phi(\vec{x}_{i}),\phi(\vec{x}_{j}) } \rangle
$$

donde $\langle .,. \rangle$ es el producto punto, $M > N$ y $\phi$ es la transformación del espacio de características. La gracia de este _truco_ es que permite operar sobre espacios de mayor dimensionalidad (donde sí existe $h$) pero dentro del espacio de menor dimensionalidad (lo que podría ser muy costoso computacionalmente de lo contrario).

Sobre _kernels_ hay algunos muy populares, por ejemplo

- Polinomial
- _Radial Basis Function_
- Sigmoidal

Una definición más completa sobre SVM puede leerse en [esta página](https://ml.berkeley.edu/blog/2016/12/24/tutorial-2/).

## Máquinas de factorización

Las SVM presentan problemas sobre datasets muy poco densos, problema que es abordado por las máquinas de factorización, las que incorporan la interacción entre distintas variables en el dataset. Para dos interacciones, [Rendle, 2010](https://www.ismll.uni-hildesheim.de/pub/pdfs/Rendle2010FM.pdf) define el modelo de una FM como

$$
\hat{y}(x) = w_{0} + \sum_{i=1}^{n} w_{i} x_{i} + \sum_{i=1}^{n} \sum_{j=i+1}^{n} \langle {v_{i},v_{j}} \rangle  x_{i} x_{j}
$$

Reconocemos en $\langle {v_{i},v_{j}} \rangle$ un _kernel_ polinomial de la forma

$$
\langle {v_{i},v_{j}} \rangle = \sum_{f=1}^{k} v_{i,f} \cdot v_{j,f}
$$

En este caso el _kernel trick_ permite reducir la complejidad final lineal al orden de $\mathcal{O}(kn)$, sin aumentar la complejidad de la función objetivo. Para datasets menos densos como lo son aquellos usados para recomendación, las máquinas de factorización operan mucho mejor que otros algoritmos, aunque sus aplicaciones no se limitan sólo a _SR_.

## Código

- Steffen Rendle creó [LibFM](http://www.libfm.org/), una librería para implementaciones de FM en C++ disponible en github.
- Existen otras implementaciones en _Spark_ para aprovechar la parelización en [este repositorio de Github](https://github.com/blebreton/spark-FM-parallelSGD)

## The end

No quedan más partes, ¡Con esto cerramos esta serie!