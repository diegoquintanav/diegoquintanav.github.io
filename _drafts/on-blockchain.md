---
layout: post
title:  "Acerca de Blockchain"
date:   2017-10-26 17:01:00 -0600
categories: jekyll update
lang: es
ref: blockchain1
published: false
---

Contenidos

1.  Introducción
1.  *Hype* de bitcoin y blockchain
1.  Más técnico
1.  *Hands on*
1.  Ejemplos de aplicación


# Introducción

¿Qué es Blockchain? ¿Qué es bitcoin? Probablemente una [búsqueda en google](http://lmgtfy.com/?q=qu%C3%A9+es+blockchain) resuelva rápidamente estas preguntas. Un día sábado por la mañana fuimos con unos amigos a una charla realizada en las oficinas de [Cryptomarket](www.cryptomkt.com) y fuimos testigos del *hype* ocurriendo *in situ*. Era una locura.

Mi experiencia con el dinero es bien pobre *(pun intended)*. Digamos que aún soy un jugador amateur en este tema, pero que leo sobre el tema cada vez que puedo. Tengo algunas inversiones en dinero local, y nada de dinero digital. 

Mi humilde aporte de estas mini historias es documentar lo que *yo entiendo* de todo este asunto, y quizás ahondar un poco en las tecnologías que se esconden en esta, la tan potencial *nueva* revolución del dinero.

## Por qué es bueno saber de esto

Lo primero que conviene decir aquí es que es bueno entender como funciona el dinero, o las bases de porqué el dinero *funciona*, y porqué un pedazo de papel equivale a un litro de bencina o a un kilo de pan. Creo que resulta más fácil transportar estos conceptos hacia la filosofía de BitCoin. 

Colgándome del rollo del clásico *padre rico padre pobre*,  escencialmente hay que **entender como funciona el dinero para no ser pobre**. *Educarse financieramente* en términos de Robert Kiyosaki, el autor. Algo que puede sonar obvio *ahora* pero en los años de su primera publicación se vendía como pan caliente. 

Este concepto es lo único rescatable del libro, y el resto es un puñado de apreciaciones personales del autor sobre educación y éxito, bajo ese prisma del *sueño americano*. En lo personal, el tema de la pobreza es de una complejidad mucho mayor, y no se reduce a *querer dejar de ser pobre*. Esto da para otro tema.

<!-- Parte 1 -->
# El *Hype* de Bitcoin, Ethereum y Blockchain

1. [ ] breve historia de bitcoin, nakamoto, y el problema de los generales bizantinos
1. [ ] breve historia de blockchain
1. [ ] ejemplos de éxito, la bolsa, caídas y subidas
1. [ ] Extensibilidad de blockchain, casos de aplicación
1. [ ] Ethereum
1. [ ] *What's next*

## El problema de los generales bizantinos

[Este paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/12/The-Byzantine-Generals-Problem.pdf)

http://marknelson.us/2007/07/23/byzantine/


## Bitcoin y Nakamoto

https://bitcoin.org/bitcoin.pdf

https://steemit.com/bitcoin/@dr-physics/bitcoin-white-paper-explained-bitcoin-made-easy

<!-- Parte 2 -->
# Más técnico, más rollo

1. [ ]  El dinero, el tema de la confianza
1. [ ]  *Wealth of nations*
1. [ ]  *Blockchain explained*
1. [ ]  Proof of work y proof of S.
1. [ ]  Criterios de diseño en distintas monedas, diferencias técnicas
1. [ ]  Caso de estudio: Bitcoin
1. [ ]  Caso de estudio: Ethereum
1. [ ]  Bibliografía

<!-- Parte 3 -->
# Ethereum: *Hands on* 
1.  [ ] Ejemplo visto en el workshop: Easy mode
1.  [ ] Ejemplo visto en Medium: Normal mode
1.  [ ] Ejemplo mío, diseño de contrato: Normal mode

## Tokens

Hay muchas formas de comenzar a jugar con estas cosas. La forma más fácil es a través de *Metamask*, el que permite ejecutar aplicaciones que corren sobre *ethereum* sin necesidad de descargar el blockchain completo (~30GB) en el laptop personal. Si bien esto es algo bueno, también existen beneficios de tener esto descargado (*Insertar referencia aquí*).

Metamask existe principalmente como una extensión para *Chrome*, por lo que la instalación es relativamente sencilla. 

<!-- completar el tutorial easy aquí -->

## Smart contracts

A mi parecer, la diversidad de código se da sobretodo en los *Smart Contracts*, documentos que son compilados en contratos inteligentes que operan sobre la red Ethereum y consumen *Ether*. Un tutorial muy completo para hacer un contrato inteligente se encuentra [aquí](https://medium.com/@mvmurthy/full-stack-hello-world-voting-ethereum-dapp-tutorial-part-1-40d2d0d807c2).

Este tutorial está en inglés, pero es muy completo. Entre las cosas que se logran están

1.  En la parte 1
    1.  El uso de ```node``` y ```npm``` como entorno de desarrollo de  contratos inteligentes
    1.  El uso de ```tesrpc``` para simular cuentas falsas sobre    Ethereum e interactuar con el blockchain a través de RPCs, o [*    (Remote procedure calls)*]  (http://searchmicroservices.techtarget.com/definition/Remote-Proced   ure-Call-RPC).
    1.  El uso de ```solc``` para compilar contratos y ```web3js```     para interactuar con el blockchain
    1.  Interfaz simple del contrato usando HTML y JS para visualizar un sistema de votos basado en blockchain.
1.  En la parte 2
    1.  asdf
    1.  

## Otros


