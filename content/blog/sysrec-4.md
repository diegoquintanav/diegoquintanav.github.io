Title: Sistemas recomendadores, parte 4
Date: 2017-11-02 18:01:00 -0600
Category: Recommender Systems
Tags: recommender systems; recsys
Slug: recsys-4
Authors: Diego Quintana
Summary: Cuarta parte de sistemas recomendadores
Status: draft

<!-- Modified: 2010-12-05 19:30 -->

<!-- entry 4, clase al 08.11 -->
<!-- Hoy -->
<!-- *  Evaluación -->
<!-- *  Laboratorio -->
<!-- *  usando *Bag of Words* -->
<!-- *  LDA -->
<!-- *  Usando un software llamado *gensim* -->

# _Previously_

En la [parte 3]({filename}/blog/sysrec-3.md) se comentaron algunos SR basados en contenido, quedando para esta parte comentar un poco sobre sistemas _híbridos_ y sobre métricas usadas en la evaluación de un SR.

## Sistemas de recomendación híbridos

Se trata de una familia de SR que combinan elementos de las clasificaciones vistas antes, _content based_ (CB) y _collaborative filtering based_ (CF). Al respecto en [Burke, 2007](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.88.8200&rep=rep1&type=pdf) y en [Adomavicius, 2005](http://blog.ag-nbi.de/wp-content/uploads/2015/10/adomavicius-recsys.pdf) se hace una revisión extensa sobre el tema

Según Burke existen 7 formas distintas de _hibridizar sistemas_,

1. **Weighted** Los puntajes o scores de las recomendaciones provenientes de distintos SR son combinadas en una sola recomendación
2. **Switching** El SR es intercambiado dependiendo de la situación
3. **Mixed** Recomendaciones de distintos SR se presentan al mismo tiempo
4. **Feature combination** Las características de distintos SR se combinan en un nuevo algoritmo de recomendación.
5. **Cascade** Un SR refina las recomendaciones de otro SR
6. **Feature augmentation** La recomendación de un SR es usada como parámetros de entrada para otro SR
7. **Meta-level** El modelo aprendido por un SR es usado como información de entrada para otro SR

Estas siguen 3 diseños generales

### Monolítico

Se refiere a la unión de dos o más SR en uno solo. Ejemplos de esto son aquellos que implementan _Feature augmentation, Feature combination_

![monolithic]({filename}/images/monolithic_hybrid.png)

### Paralelizado

Se refiere a la ejecución de diversos SR en paralelo, cuyas recomendaciones son combinadas en la salida. Ejemplos de esto implementan _Weighted, Switching, Mixed_

![parallel]({filename}/images/parallel_hybrid.png)

### Pipeline

Se refieren a los SR cuya entrada es la salida de otro SR, siguiendo una ejecución en serie. Ejemplos de esto implementam _Cascade, Meta-Level_

![pipeline]({filename}/images/pipeline_hybrid.png)

## Evaluación de un recomendador

### Métricas en contexto de clasificación

En términos generales el problema de recomendación es un problema de clasificación, en el sentido que un SR intenta recomendar los elementos que pertenecen al grupo de intereses de un usuario cualquiera. En esta tarea de clasificación un SR puede fallar o acertar, y en base a estos dos escenarios es que se definen distintas métricas que permitan cuantificar la _calidad_ de un clasificador.

La primera herramienta que uno debería considerar es la matriz de confusión, la que puede leerse con más detalle en [dataschool](http://www.dataschool.io/simple-guide-to-confusion-matrix-terminology/).

Una matriz de confusión es una representación de la cantidad de aciertos por clase en una tarea _de clasificación_. En este sentido se habla de

- Verdaderos positivos, TP
- Verdaderos negativos, TN
- Falsos positivos, FP
- Falsos negativos, FN

En el contexto de SR, sin embargo, se define un _acierto_ en un conjunto de recomendaciones como _relevante_. La definición de relevancia puede variar dependiendo de cada caso, pudiendo ser

- Un usuario hace click en un link de una lista de links recomendados
- Un usuario compra un libro recomendado
- Un usuario comparte un video sugerido

Entonces estas nuevas clases dan lugar a una serie de indicadores que ayudan a valorizar un SR por sobre otro en un caso determinado. Si se visualizan estas clases en un diagrama de conjuntos, se tiene

![venn1]({filename}/images/venn1.png)

De aquí se tiene que la **Precisión** es la fracción de instancias _relevantes_ obtenidas en alguna tarea en específico, del resultado de recomendaciones.

$$\mbox{precision} = \frac{\mbox{TP}}{\mbox{TP}+\mbox{FP}}$$

O en el contexto de SR,

$$\mbox{precision} = \frac{|\mbox{recomendados} \cap \mbox{relevantes}|}{|\mbox{recomendados}|}$$

Para el caso del diagrama, la recomendación o el SR tiene una precisión de $2/5=0.4$. La _precisión_ entonces mide qué tan posible es obtener los elementos relevantes _con la menor cantidad_ de recomendaciones.

**Recall** o _true positive rate_ (TPR) se refiere a la fracción de instancias relevantes obtenidas del total de instancias relevantes, o bien

$$
\mbox{TPR} = \mbox{recall} = \frac{\mbox{TP}}{\mbox{TP}+\mbox{FN}}
$$

O en términos de recomendaciones

$$
\mbox{recall} = \frac{|\mbox{recomendados} \cap \mbox{relevantes}|}{|\mbox{relevantes}|}$$

Para el caso del diagrama, el _recall_ del SR es de $2/10=0.2$

Ambos, precision y _recall_ tienen una relación inversa, tal que el _recall_ disminuye a medida que la precisión aumenta. En este sentido, para un clasificador es posible graficar su desempeño en términos de la curva _precision vs recall_ o curva PR.

Esta curva puede transformarse a otro espacio más conocido, llamado [curva ROC](https://en.wikipedia.org/wiki/Receiver_operating_characteristic) o _receiving operating characteristic curve_, en el cual se grafica el _recall_ como TPR o _true positive rate_ versus **FPR** o _false positive rate_.

[![roc_video](http://img.youtube.com/vi/OAl6eAyP-yo/0.jpg)](http://www.youtube.com/watch?v=OAl6eAyP-yo "ROC Curve explained")

Conviene tener en cuenta que **Ambas curvas no son equivalentes** y la curva PR describe mejor el desempeño de clasificadores en casos donde hay un desbalance importante de clases. Una comparación completa entre ambas curvas puede leerse [aquí](http://pages.cs.wisc.edu/~jdavis/davisgoadrichcamera2.pdf)

$$
\mbox{FPR} = {\frac {\mbox{FP}}{\mbox{N}}}={\frac {\mbox{FP}}{\mbox{FP+TN}}}
$$

![roc_vs_pr]({filename}/images/roc_vs_pr.png)

Finalmente, algunas notas sobre este tema

- Considerando que hay tipos de SR distintos que generan resultados distintos, estas métricas resultan útiles para poder comparar los distintos modelos, por ejemplo a través de _A/B Testing_ o tests de hipótesis.
- Dependiendo del caso, puedo darse la necesidad de usar algoritmos con mayor _recall_ que precisión i.e. si quiero saber cuándo es el siguiente partido de chile, me importa más usar un SR que recomiende el _resultado correcto_, en vez de un SR que me recomiende _la mejor página con el resultado_. En este caso requiero mayor _recall_ que precisión.
- Es bueno recordar que estas métricas evalúan _conjuntos de recomendaciones_, no las recomendaciones en sí.

### Métricas en el contexto de recomendadores

En el contexto de recomendadores existen muchos otros indicadores que ayudan a evaluar un SR, tales como

- Mean reciprocal rank (MRR)
- Precision at N (P@N)
- Mean Average Precision (MAP)
- DCG y nDCG
- Coverage index
- Diversity index
- Mean Percentage Ranking

<!-- ## Diversity

Si alguien le gusta el *colo colo*, y le recomiendo sólo noticias del mismo equipo, la diversidad es muy baja. Si en cambio le recomiendo noticias de fútbol, añado diversidad a mi conjunto de recomendaciones. Esto apunta a resolver el problema de *burbujas de información*, algo que se puede hacer de manera programática y controlada. -->

## A continuación

En la [parte 5 y final]({filename}/blog/sysrec-5.md) se verán las _Máquinas de Factorización_
