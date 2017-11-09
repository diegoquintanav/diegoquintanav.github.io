# Clase 8.11.2017

## repaso 

en la clase anterior hablamos de
*  TF-LDA
*  LDA
*  Hicimos un laboratorio con Solr

Hoy
*  Evaluación
*  Laboratorio
    *  usando *Bag of Words*
    *  LDA
    *  Usando un software llamado *Sensing*

## Evaluación de una lista de recomendaciones

Si se consideran los elementos recomendados como un conjunto $$ S $$ y los elementos relevantes como $$ R $$ se define la *precisión*

> Qué es la relevancia? Los que están más arriba en los resultados de búsqueda, por ejemplo, son más relevantes

$$ \mbox{precision} = \frac{|\mbox{recomendados} \cap \mbox{relevantes}|}{|\mbox{recomendados}|} $$

Considerando que hay algoritmos distintos que podrían generar resultados distintos, por ejemplo una lista de resultados $$ S_1 $$ y otra $$ S_2 $$.

```
S_1 = {1:{index_recomendación:101, click:True},
        2:{index_recomendación:70, click:False},
        3:{index_recomendación:10, click:False}}

S_2 = {1:{index_recomendación:100, click:False},
        2:{index_recomendación:80, click:False},
        3:{index_recomendación:10, click:True}}
```

S2 es peor que S1

Digamos que pruebo ambos algoritmos, en modo *A/B Testing* y según los clicks de usuarios pueden ver cuáles son más relevantes en función de cuales resultados son clickeados *primero*.

<!-- *Luego habla de una ground truth, no entendí* -->

Además se define el *recall* como

$$ \mbox{recall} = \frac{|\mbox{recomendados} \cap \mbox{relevantes}|}{|\mbox{relevantes}|} $$

*Explica el diagrama de venn de elementos recomendados*

Entonces
*  Si aumenta la cantidad de recomendaciones, la precisión es baja, pero la noción de relevancia se pierde
*  *Explicación del **recall***
    *  Va entre 0 y 1
    *  Su objetivo es saber qué tan bien se obtienen elementos relevantes para el usuario. 
    *  Ejemplo si mi dataset es de 10e6 y recomiendo 10e6 elementos, el recall es de 1


*  *Precision* mide que tan posible es obtener los elementos relevantes con menos recomendaciones. Si las recomendaciones son bajas y  $$ |\mbox{relevantes}  \cap \mbox{recomendados}| $$  es fijo, la precision sube 


*  Dependiendo del caso, puedo requerir algoritmos con mayor recall que precisión i.e. predecir cuándo es el siguiente partido de chile, me importa recomendar el *resultado correcto*, no *la mejor página con el resultado*, por lo que requiero mayor recall que precisión.
*  Estamos evaluando conjuntos, no *ratings*.

### Ejemplo 1
<!-- slide 5 -->

El ```x20``` es la base de datos relevantes. Hay 20 elementos relevantes en total. El número de elementos recomendados puede variar según el algoritmo usado

Recomendador 1
*  10 recomendaciones
*  5 relevantes
*  precisión 5/10
*  recall 5/20

Recomendador 2
*  5 recomendaciones
*  3 relevantes
*  precisión 3/5
*  recall 3/20

## Mean reciprocal rank (MRR)

<!-- usado en? para qué? -->

Recomendador 1:
*  1/2

Recomendador 1:
*  1/2

## Precision at N (P@N)

Me muevo hasta la posición $$ n $$ y cuento la cantidad de elementos relevantes.

$$ \mbox{p(n)} = \frac{\sum_{i=1}^{n} rel(i)}{n} $$

donde $$ rel(i) $$ es 1 si el elemento $$ i $$ es relevante.

### Ejemplo *Precision at 5*

Recomendador 1:
*  2/5

Recomendador 1:
*  3/5

<!-- nota aparte. menciona. el Funksvd busca minimizar el error en los ratings predichos -->

## Mean Average Precision (MAP)

## DCG y nDCG

métrica para evaluar el ranking de un conjunto

## Coverage

*  UB-CF tiene problemas de *cold start*, resuelvo proponiendo llos más populares
*  IB-CF tiene el problema de *new item*

El coverage apunta a medir a cuántos usuarios/items (en porcentaje) del pool de usuarios/items no se les pudo hacer recommendaciones. 

## Diversity

Si alguien le gusta el *colo colo*, y le recomiendo sólo noticias del mismo equipo, la diversidad es muy baja. Si en cambio le recomiendo noticias de fútbol, añado diversidad a mi conjunto de recomendaciones. Esto apunta a resolver el problema de *burbujas de información*, algo que se puede hacer de manera programática y controlada.

## Mean Percentage Ranking

## Comparando métricas de performance entre recomendadores

Se hace con test de hipótesis

Considerando dos recomendadores $$ A_1 $$ y $$ A_2 $$, y una BD de 100 usuarios. Un test de hipótesis es *T-Test*


# Práctico

*  descargar enunciado
*  correr MV 

*  Cambiar el número de tópicos o ```topic_number``` de 5 a 10.



Como copiar weas entre MV, usando virtualbox
*  Crear una interfaz nueva en virtualbox en *global tool* y dejándola como dchp
*  en el guest instalar ```ssh-server``` y arrancar servicio si no está arriba
*  en el file manager del host ingresar a ```sftp://ubuntu@192.168.56.3/home/ubuntu```, con ```ctrl+l```, donde la dirección es la de la interfaz creada, la que se puede ver en el guest a través de ```ifconfig```
*  alterntivamente desde el host hacer ```ssh```    
*  para correr ejemplos descargar ```nltk``` y ```gensim```
