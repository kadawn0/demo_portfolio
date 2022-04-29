# proyectoIIC3724

En este trabajo se realizarán los siguientes clasificadores.

## Contenidos

- [proyectoIIC3724](#proyectoiic3724)
  - [Fechas importantes](#fechas-importantes)
  - [Método de trabajo](#método-de-trabajo)
    - [Repartición del trabajo](#repartición-del-trabajo)
    - [Presentación final:](#presentación-final)
  - ["Estados del arte" dentro del curso](#estados-del-arte-dentro-del-curso)
  - [Medida de la similitud](#medida-de-la-similitud)
  - [PCA de scikit learn: Whiten](#pca-de-scikit-learn-whiten)
  - [Métrica aprendida](#métrica-aprendida)
  - [Clasificadores](#clasificadores)
    - [LBP de 1x1 con escala de grises.](#lbp-de-1x1-con-escala-de-grises)
  - [Resultados sobre LBP 8x8](#resultados-sobre-lbp-8x8)
    - [Primer experimento](#primer-experimento)
    - [Segundo experimento](#segundo-experimento)
    - [Tercer experimento](#tercer-experimento)
    - [Cuarto experimento](#cuarto-experimento)
    - [Quinto experimento](#quinto-experimento)
    - [Sexto experimento](#sexto-experimento)
    - [Séptimo experimento](#séptimo-experimento)
    - [Octavo experimento](#octavo-experimento)
    - [Noveno experimento](#noveno-experimento)
    - [Décimo experimento](#décimo-experimento)
    - [Decimoprimer experimento](#decimoprimer-experimento)
    - [Decimosegundo experimento](#decimosegundo-experimento)
    - [Decimotercer experimento](#decimotercer-experimento)
  - [Referencias](#referencias)

## Fechas importantes

- Viernes 5 de julio, 10:00 horas: presentación final del proyecto (Edificio San Agustín Piso 4, oficina del profesor Domingo Mery).

## Método de trabajo

Usaremos las siguientes herramientas para armar los clasificadores, repartidas de la siguiente forma

### Repartición del trabajo

- Nicolás: Preprocesamiento (Alienamiento y quitar lineas del carnet)
- Patricio: Deep face, HOG + Gabor + Haralick + Hu Moments + LBP
- Catalina: Extraccion de features: Eigenface/HoG
- Alfonso: Aplicar Metric Learning

### Presentación final

En base al email que envió el profesor:

1.  Power Point o PDF

    1. Introducción.
    2. Estados del arte (mínimo 3 papers).
    3. Método **propuesto** en detalle, con el diagrama respectivo.
    4. Resultados: mostrar qué fue lo que resultó versus lo que no.
    5. Conclusiones: qué funciona y qué no, de manera **científica**; por qué funciona lo que funciona, por qué no funciona lo que no funciona. También mostrar trabajos futuros.

2.  Demo: es importante que esté bien preparada (no improvisada) y que muestre la funcionalidad del software hecho, que los experimentos sean buenos. Que se vean los resultados con y sin mejoras y se tengan las métricas FMR, FNMR, y d prima. Además, obtener gráficos, basados en los datos reales.

3.  Preguntas del profesor: apuntan a evaluar el proyecto, pero también a manejo de la materia para evaluar individualmente.

## "Estados del arte" dentro del curso

**NOTA**: estos datos son solamente de referencias, y es bueno que puedan ser verificados. Puede haber información equivocada o incompleta.

| Preprocesamiento                    |         Extracción         | Selección |       Métrica        | **Valor de d'** |
| :---------------------------------- | :------------------------: | :-------: | :------------------: | --------------: |
| Notch con alineamiento              |          LBP 3x3           |    SFS    |   Metric Learning    |        **3.55** |
| Notch con alineamiento              |            DLib            |    NA     |          ?           |        **2.16** |
| Ecu. brillo c/histograms &sin rayas |   Face Net (capa lineal)   |    NA     |          ?           |        **2.09** |
| Data augmentation (?)               |          Face Net          |    NA     |          ?           |         **1.8** |
| Crop                                |            DLib            |    NA     |          ?           |         **1.8** |
| Notch **o** grayscale               |          VGG Face          |    NA     | Similitud de cosenos |        **~1.8** |
| Ecu. brillo c/histograms &sin rayas |   Face Net (embeddings )   |    NA     |          ?           |        **1.79** |
| Black/White, denoise                |          VGG Face          |    NA     | Similitud de cosenos |        **1.64** |
| Promedio de frecuencias (Fourier)   |      FaceNet y ResNet      |    NA     | Similitud de cosenos |        **1.57** |
| Alineamiento y filtrado             |          VGG Face          |    NA     |          ?           |       **1.534** |
| Notch con alineamiento              |   VGG Face **o** Resnet    |    NA     |          ?           |         **1.5** |
| NA                                  | TripletLoss (hardTriplets) |    NA     |          ?           |        **1.20** |

## Medida de la similitud

Para medir la similitud se hace lo siguiente:

- Se construye una matriz X_a y una matriz X_b. Es necesario que las filas de éstas se normalicen. Las filas son las features obtenidas con la extracción-selección-transformación, y las columnas corresponden a cada feature, según el caso. Luego se hace la multiplicación entre ambas, según la ecuación:

M = X_a \* X_b^t

Esta matriz M obtiene para cada par de personas A y B, su representación en cuanto a similaridad.

En la diagonal de la matriz M se encuentra la similaridad. La diagonal tiene alta similaridad, debido a que corresponde a
la distribución de los **genuinos**, mientras que los elementos fuera de la diagonal representan la distribución de los **impostores**. Ambas distribuciones se llevan a un gráfico que las representa. Sobre eso se calcula una distancia **d_prime**, que mientras más alta, muestra una mejor separación de los genuinos e impostores.


## PCA

Principal Component Analysis (PC A) (e.g. [3]) is an orthogonal basis transformation.
The new basis is found by diagonalizing the centered covariance matrix of a data set
{Xk E RNlk = 1, ... ,f}, defined by C = ((Xi - (Xk))(Xi - (Xk))T). The coordi-
nates in the Eigenvector basis are called principal components. The size of an Eigenvalue corresponding to an Eigenvector v of C equals the amount of variance in the direction
of v. Furthermore, the directions of the first n Eigenvectors corresponding to the biggest
n Eigenvalues cover as much variance as possible by n orthogonal directions. In many ap-
plications they contain the most interesting information: for instance, in data compression,
where we project onto the directions with biggest variance to retain as much information
as possible, or in de-noising, where we deliberately drop directions with small variance.

## PCA de scikit learn: Whiten

whiten : bool, optional (default False)
When True (False by default) the components\_ vectors are multiplied by the square root of n_samples and then divided by the singular values to ensure uncorrelated outputs with unit component-wise variances.

Whitening will remove some information from the transformed signal (the relative variance scales of the components) but can sometime improve the predictive accuracy of the downstream estimators by making their data respect some hard-wired assumptions.

## Métrica aprendida

Es posible aprender una métrica que permita separar los impostores de los genuinos. Acá se utilizan las mismas matrices, X_a, y X_b. Con ellas se obtiene la diferencia al cuadrado entre cada par de vectores, y para esto se calcula la matriz:

D = X_a - X_b

De esta forma al calcular:

D2 = D^t \* D

Lo que se obtiene es el cuadrado de las distancias. Esto corresponde a la distancia euclidiana, pero una variante podría considerar:

D2*M = D^t * M^t \_ M \* D

Entonces se debe encontrar la matriz tal que, al graficar sus distibuciones, obtengan un coeficiente d' que sea más elevado.

## Clasificadores

### LBP de 8x8 con escala de grises.

El primer clasificador es un lbp con ventanas de 8x8. Sobre estos vectores se realizará, utilizando el método de distancia
_d prime_, la obtención de los features que mejor separan, en este caso según lbp.

## Resultados sobre LBP 8x8

### Primer experimento

Producto cartesiano:

- Pca (opc en paréntesis): without pca (-1), pca (0), MLKR (1), pca whiten (3).
- `n_components`: 100, 200, 300 (200 en la tabla no aparece explícito).
- Métodos: distancia euclidiana, similaridad del coseno, mahalanobis (RCA), NCA.

**Nota**: Los resultados están ordenados según `d_prime` en orden descendiente. Se dejarán solamente los mejores 5 resultados, por brevedad, calculados al momento de **terminar este experimento**. Los resultados completos se encuentran en el archivo _results/data.json_.

| method                         | d_prime  | FMR         | FNMR    | time    |
| ------------------------------ | -------- | ----------- | ------- | ------- |
| nca_distances, with pca 3, 300 | 0.622499 | 0.000297365 | 0.66497 | 292.618 |
| nca_distances, with pca 0, 100 | 0.479543 | 0.00137517  | 2.5645  | 60.0874 |
| nca_distances, with pca 3      | 0.388473 | 0.000844077 | 2.00172 | 216.718 |
| nca_distances, with pca 0      | 0.37307  | 0.000401036 | 1.0971  | 85.1667 |
| nca_distances, with pca 0, 300 | 0.329419 | 0.000317038 | 1.09743 | 133.619 |

**Nota**: es muy importante que algunos algoritmos no pueden ser ejecutados; por ejemplo la opción 2 no se utiliza por este motivo, pero habría que analizar los resultados. El producto cartesiano tampoco es exhaustivo, porque hay opciones que son inviables.

### Segundo experimento

Dado los experimentos anteriores, hay que explotar la distancia nca. Se observa que el mejor `d_prime` va de la mano con el pca opción 3 (y 0).

A continuación se prueba el siguiente producto cartesiano:

- Pca: 0 y 3.
- `n_components`: 50, 150, 250, 350, 400.
- Métodos: NCA.

Los mejores 5 resultados después de correr estos experimentos, son:

| method                         | d_prime  | FMR         | FNMR     | time    |
| ------------------------------ | -------- | ----------- | -------- | ------- |
| nca_distances, with pca 3, 400 | 0.79907  | 0.000276384 | 0.586159 | 282.049 |
| nca_distances, with pca 3, 350 | 0.647823 | 0.000821884 | 1.81425  | 412.024 |
| nca_distances, with pca 3, 300 | 0.622499 | 0.000297365 | 0.66497  | 292.618 |
| nca_distances, with pca 3, 250 | 0.567469 | 0.000270359 | 0.69716  | 291.043 |
| nca_distances, with pca 0, 50  | 0.489306 | 0.000698254 | 0.874688 | 150.433 |

### Tercer experimento

Finalmente, se explota solamente `nca_distances` con la opción 3 de pca.
Producto cartesiano:

- Pca: 3
- `n_components`: 500, 600, 700, 800, 900, 1000.
- Métodos: NCA

Los mejores 5 resultados luego de los tres experimentos son:

| method                          | d_prime  | FMR         | FNMR     | time    |
| ------------------------------- | -------- | ----------- | -------- | ------- |
| nca_distances, with pca 3, 700  | 1.0506   | 0.000335416 | 0.646106 | 419.398 |
| nca_distances, with pca 3, 1000 | 1.02409  | 0.000283972 | 0.496863 | 288.975 |
| nca_distances, with pca 3, 900  | 0.986958 | 0.000304293 | 0.515819 | 327.75  |
| nca_distances, with pca 3, 600  | 0.947709 | 0.000312814 | 0.575932 | 302.749 |
| nca_distances, with pca 3, 800  | 0.944716 | 0.000294027 | 0.545283 | 390.874 |

### Cuarto experimento

Se explora otro método de Mahalanobis, este se denomina `lmnn_distances`. Este experimento es netamente para introducir este método, por lo que consta de una sola prueba. Se reduce la cantidad de componentes para que funcione.
Producto cartesiano:

- Pca: 3
- `n_components`: 50
- Métricas: LMNN

Los mejores resultados luego de este experimento son:

| method                          | d_prime  | FMR         | FNMR     | time    |
| ------------------------------- | -------- | ----------- | -------- | ------- |
| nca_distances, with pca 3, 700  | 1.0506   | 0.000335416 | 0.646106 | 419.398 |
| nca_distances, with pca 3, 1000 | 1.02409  | 0.000283972 | 0.496863 | 288.975 |
| nca_distances, with pca 3, 900  | 0.986958 | 0.000304293 | 0.515819 | 327.75  |
| nca_distances, with pca 3, 600  | 0.947709 | 0.000312814 | 0.575932 | 302.749 |
| nca_distances, with pca 3, 800  | 0.944716 | 0.000294027 | 0.545283 | 390.874 |

Como este nuevo resultado no es parte de los 5 mejores, se muestran también otros resultados y se destaca este último resultado:

| method                             | d_prime      | FMR         | FNMR     | time    |
| ---------------------------------- | ------------ | ----------- | -------- | ------- |
| nca_distances, with pca 3, 400     | 0.79907      | 0.000276384 | 0.586159 | 282.049 |
| nca_distances, with pca 3, 350     | 0.647823     | 0.000821884 | 1.81425  | 412.024 |
| nca_distances, with pca 3, 300     | 0.622499     | 0.000297365 | 0.66497  | 292.618 |
| nca_distances, with pca 3, 250     | 0.567469     | 0.000270359 | 0.69716  | 291.043 |
| **lmnn_distances, with pca 3, 50** | **0.524688** | 9.95761e-05 | 0.254607 | 253.291 |
| nca_distances, with pca 0, 50      | 0.489306     | 0.000698254 | 0.874688 | 150.433 |
| nca_distances, with pca 0, 100     | 0.479543     | 0.00137517  | 2.5645   | 60.0874 |
| nca_distances, with pca 0, 150     | 0.474908     | 0.000609588 | 1.31808  | 75.1924 |

Se puede observar en esta última tabla, que LMNN establece un _threshold_ entre utilizar pca 3 y utilizar pca 0, hasta este momento.

### Quinto experimento

Se prueba con PCA 0. Este método es **extremadamente lento**, y no corresponde a las 5 primeras posiciones; marca un _threshold_ hasta ahora entre nca con pca 0 y menos features, y pca 0 y más features.

Producto cartesiano:

- Pca: 0
- `n_components`: 50
- Métricas: LMNN

| method                         | d_prime  | FMR         | FNMR       | time    |
| ------------------------------ | -------- | ----------- | ---------- | ------- |
| nca_distances, with pca 0, 50  | 0.489306 | 0.000698254 | 0.874688   | 150.433 |
| nca_distances, with pca 0, 100 | 0.479543 | 0.00137517  | 2.5645     | 60.0874 |
| nca_distances, with pca 0, 150 | 0.474908 | 0.000609588 | 1.31808    | 75.1924 |
| lmnn_distances, with pca 0, 50 | 0.405186 | 2.95995e-06 | 0.00634055 | 2711.8  |
| nca_distances, with pca 3      | 0.388473 | 0.000844077 | 2.00172    | 216.718 |
| nca_distances, with pca 0      | 0.37307  | 0.000401036 | 1.0971     | 85.1667 |
| nca_distances, with pca 0, 250 | 0.353161 | 0.000787474 | 2.10552    | 96.4815 |
| nca_distances, with pca 0, 300 | 0.329419 | 0.000317038 | 1.09743    | 133.619 |
| nca_distances, with pca 0, 350 | 0.326586 | 0.000368017 | 1.13699    | 165.18  |

### Sexto experimento

Se vuelve a probar con PCA 3, que obtiene resultados mejores que PCA 0 (para lmnn) y en menos tiempo.

Producto cartesiano:

- Pca: 3
- `n_components`: 55, 60, 65, 45, 40
- Métricas: LMNN

| method                             | d_prime  | FMR         | FNMR     | time    |
| ---------------------------------- | -------- | ----------- | -------- | ------- |
| nca_distances, with pca 3, 250     | 0.567469 | 0.000270359 | 0.69716  | 291.043 |
| **lmnn_distances, with pca 3, 65** | 0.560125 | 0.000139351 | 0.326311 | 303.579 |
| **lmnn_distances, with pca 3, 60** | 0.556465 | 0.00013124  | 0.290771 | 287.442 |
| **lmnn_distances, with pca 3, 50** | 0.524688 | 9.95761e-05 | 0.254607 | 253.291 |
| **lmnn_distances, with pca 3, 55** | 0.503715 | 0.000110072 | 0.268622 | 266.589 |
| **lmnn_distances, with pca 3, 45** | 0.49867  | 9.76062e-05 | 0.205195 | 222.187 |
| nca_distances, with pca 0, 50      | 0.489306 | 0.000698254 | 0.874688 | 150.433 |

Tampoco corresponden a los mejores valores, pero se observa que el rendimiento aumenta junto con la cantidad de features del PCA.

### Séptimo experimento

Se vuelve a retomar la línea de NCA del tercer experimento, probando nuevamente distintas cantidades de features. Con **;** se separan los valores cercanos a 700 y a 1000, que en el experimento 3 dieron los mejores resultados.

Producto cartesiano:

- PCA: 3
- `n_components`: 665, 670, 675, 680, 685, 690, 695, 705, 710 **;** 1100, 1050, 1025, 975
- Métricas: NCA

Se muestran los mejores 5 resultados, que contemplan parte de lo calculado en este experimento, y **aumentando nuevamente** el valor de d'. Se destacan los nuevos resultados en la tabla:

| method                             | d_prime | FMR         | FNMR     | time    |
| ---------------------------------- | ------- | ----------- | -------- | ------- |
| nca_distances, with pca 3, **975** | 1.10109 | 0.000292353 | 0.511958 | 356.2   |
| nca_distances, with pca 3, 700     | 1.0506  | 0.000335416 | 0.646106 | 419.398 |
| nca_distances, with pca 3, **660** | 1.05032 | 0.000302409 | 0.642893 | 384.343 |
| nca_distances, with pca 3, **680** | 1.0291  | 0.000265845 | 0.607324 | 365.943 |
| nca_distances, with pca 3, 1000    | 1.02409 | 0.000283972 | 0.496863 | 288.975 |

### Octavo experimento

NCA es **aleatorio**. También lo son la mayoría de las métricas utilizadas, por lo que se hace necesario **repetir** las mediciones. Este experimento no calcula cosas nuevas, sino que repite experimentos pasados, para ver cómo varían los resultados producto de la aleatoriedad. **PCA**, por otro lado, es aleatorio también.

Producto cartesiano:

- PCA: 3
- `n_components` 950, 950, 950
- Métricas: NCA

Resultados:
Se presentan los tres mejores métodos hasta ahora con respecto a la media de `d_prime`. Las métricas nuevas sólo aportan información para más de un experimento.

| method                         | d_prime | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| ------------------------------ | ------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 975 | 1.10109 | 0.000292353 | 0.511958 | 356.2   | 0           | 1.10109     | 1.10109     |
| nca_distances, with pca 3, 950 | 1.058   | 0.000303417 | 0.543455 | 356.874 | 0.130123    | 0.861727    | 1.21094     |
| nca_distances, with pca 3, 700 | 1.0506  | 0.000335416 | 0.646106 | 419.398 | 0           | 1.0506      | 1.0506      |

### Noveno experimento

Se repiten muchos de los experimentos. Desde ahora esos se considerarán los más relevantes.

Producto cartesiano:

- PCA: 0, 3
- `n_components`: 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 (**5 veces cada valor**, algunos 6 veces)
- Métricas: NCA

| method                          | d_prime  | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| ------------------------------- | -------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 900  | 0.997718 | 0.000313229 | 0.520708 | 336.988 | 0.101426    | 0.839167    | 1.15843     |
| nca_distances, with pca 3, 1000 | 0.97255  | 0.000300544 | 0.524419 | 338.61  | 0.109402    | 0.809456    | 1.14685     |
| nca_distances, with pca 3, 800  | 0.962798 | 0.000285798 | 0.562416 | 347.657 | 0.0318874   | 0.926596    | 1.01693     |
| nca_distances, with pca 3, 700  | 0.953486 | 0.000318142 | 0.598895 | 369.403 | 0.08903     | 0.850795    | 1.06234     |
| nca_distances, with pca 3, 600  | 0.948373 | 0.000315779 | 0.627647 | 348.092 | 0.0087574   | 0.933142    | 0.962789    |
| nca_distances, with pca 3, 500  | 0.857136 | 0.000446657 | 0.869484 | 307.497 | 0.0867749   | 0.673929    | 0.94041     |
| nca_distances, with pca 3, 400  | 0.792635 | 0.000290792 | 0.600252 | 304.144 | 0.0124732   | 0.766366    | 0.804317    |
| nca_distances, with pca 3, 300  | 0.643028 | 0.000289496 | 0.71701  | 291.48  | 0.0181402   | 0.62026     | 0.672057    |
| nca_distances, with pca 0, 900  | 0.473959 | 0.000215674 | 0.535066 | 300.197 | 0.0124214   | 0.456005    | 0.490689    |
| nca_distances, with pca 0, 1000 | 0.472983 | 0.000233333 | 0.535374 | 336.007 | 0.0225178   | 0.429443    | 0.492183    |
| nca_distances, with pca 0, 100  | 0.466057 | 0.000852661 | 1.68383  | 64.5986 | 0.0185538   | 0.436789    | 0.496526    |
| nca_distances, with pca 0, 800  | 0.453056 | 0.000222874 | 0.548819 | 293.051 | 0.0125007   | 0.430604    | 0.465567    |
| nca_distances, with pca 0, 500  | 0.453001 | 0.000209327 | 0.607979 | 282.76  | 0.0334364   | 0.390193    | 0.489617    |
| nca_distances, with pca 0, 600  | 0.450044 | 0.000214001 | 0.5245   | 271.216 | 0.0179343   | 0.432689    | 0.473666    |
| nca_distances, with pca 0, 700  | 0.449649 | 0.000216317 | 0.536537 | 281.474 | 0.0214065   | 0.421016    | 0.487262    |
| nca_distances, with pca 3       | 0.442948 | 0.00044233  | 1.02968  | 216.642 | 0.0347573   | 0.388473    | 0.491387    |
| nca_distances, with pca 0       | 0.374457 | 0.00040496  | 1.11954  | 126.255 | 0.0181675   | 0.344985    | 0.400925    |
| nca_distances, with pca 0, 400  | 0.339396 | 0.000376413 | 1.14296  | 201.45  | 0.0345832   | 0.297038    | 0.3958      |
| nca_distances, with pca 0, 300  | 0.33939  | 0.000521386 | 1.54837  | 93.0874 | 0.00662364  | 0.329419    | 0.347969    |
| nca_distances, with pca 3, 100  | 0.276186 | 0.000400758 | 1.19934  | 201.228 | 0.0336831   | 0.230514    | 0.340748    |

Con este experimento, se observa que para NCA, PCA 3 (whiten) tiene mejor rendimiento de forma generalizada sobre PCA 0 (sin whiten). Y que se tiende a alcanzar un máximo aproximadamente a las 900 features del PCA.

### Décimo experimento

Acá la idea es mostrar que los experimentos muestran una variación con Filtro Notch cuando se utiliza versus cuando no.
Se muestran resultados que son comparativos. Para PCA 3, se muestra que el efecto del filtro lo posiciona al nivel de entre las 500 y 600 features sin filtro. Para PCA 0, el rendimiento es uno de los más bajos, casi 0.2 menor en d' que la misma versión sin el filtro.

Producto cartesiano:

- PCA: 0, 3
- `n_components`: 900 (5 veces)
- Métrica: nca_distances
- Preprocesamiento: filtro notch

| method                                       | d_prime  | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| -------------------------------------------- | -------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 600               | 0.948373 | 0.000315779 | 0.627647 | 348.092 | 0.0087574   | 0.933142    | 0.962789    |
| nca_distances, with pca 3, 900, notch_filter | 0.887255 | 0.000303054 | 0.528396 | 351.045 | 0.0976191   | 0.767347    | 1.02512     |
| nca_distances, with pca 3, 500               | 0.857136 | 0.000446657 | 0.869484 | 307.497 | 0.0867749   | 0.673929    | 0.94041     |
| nca_distances, with pca 0, 900               | 0.473959 | 0.000215674 | 0.535066 | 300.197 | 0.0124214   | 0.456005    | 0.490689    |
| nca_distances, with pca 0, 900, notch_filter | 0.275158 | 0.000229471 | 0.497616 | 349.267 | 0.0260721   | 0.250969    | 0.3289      |

### Decimoprimer experimento

Se tiene en este caso el filtro notch, y los mejores resultados se observan a continuación:

Parámetros:

- PCA: 0, 3 (0 no está entre los 5 mejores)
- Preprocesamiento: filtro_notch
- `n_components`: 100 a 1500 de 100 en 100, 5 veces cada uno (algunos 6 posiblemente por repetición)
- Métrica: nca_distances

Resultados:

| Method                                        | d_prime  | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| --------------------------------------------- | -------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 700, notch_filter  | 0.974906 | 0.000314507 | 0.541809 | 358.079 | 0.0358142   | 0.936897    | 1.02849     |
| nca_distances, with pca 3, 600, notch_filter  | 0.931376 | 0.000293188 | 0.531845 | 324.743 | 0.0300224   | 0.883149    | 0.965945    |
| nca_distances, with pca 3, 800, notch_filter  | 0.906132 | 0.000299122 | 0.545143 | 343.807 | 0.0569024   | 0.812802    | 0.967874    |
| nca_distances, with pca 3, 1000, notch_filter | 0.856041 | 0.000264774 | 0.495017 | 300.476 | 0.087139    | 0.700321    | 0.960414    |
| nca_distances, with pca 3, 900, notch_filter  | 0.847569 | 0.000318702 | 0.538396 | 346.629 | 0.086742    | 0.761881    | 1.02512     |

**Resultados sin notch**:

| method                          | d_prime  | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| ------------------------------- | -------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 900  | 0.997718 | 0.000313229 | 0.520708 | 336.988 | 0.101426    | 0.839167    | 1.15843     |
| nca_distances, with pca 3, 1000 | 0.97255  | 0.000300544 | 0.524419 | 338.61  | 0.109402    | 0.809456    | 1.14685     |
| nca_distances, with pca 3, 800  | 0.962798 | 0.000285798 | 0.562416 | 347.657 | 0.0318874   | 0.926596    | 1.01693     |
| nca_distances, with pca 3, 700  | 0.953486 | 0.000318142 | 0.598895 | 369.403 | 0.08903     | 0.850795    | 1.06234     |
| nca_distances, with pca 3, 600  | 0.948373 | 0.000315779 | 0.627647 | 348.092 | 0.0087574   | 0.933142    | 0.962789    |
| nca_distances, with pca 3, 1100 | 0.893274 | 0.000269611 | 0.488459 | 336.392 | 0           | 0.893274    | 0.893274    |

### Decimosegundo experimento

Se alinearon las imagenes, siendo rotadas no más de 15 grados para que los ojos estuvieran alineados de manera horizontal en la imagen.

Parametros:

- PCA: 3
- `n_components` 900, 925, 950, 975, 1000 (10 veces cada uno)
- Métricas: NCA

Resultados:
Se presentan los promedios de los resultados obtenidos

| method                              | d_prime  | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| ----------------------------------- | -------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 900, fa  | 0.996805 | 0.000292926 | 0.540939 | 370.949 | 0.126731    | 0.765468    | 1.151377    |
| nca_distances, with pca 3, 925, fa  | 0.893974 | 0.000316709 | 0.560287 | 354.256 | 0.098704    | 0.672047    | 1.044222    |
| nca_distances, with pca 3, 950, fa  | 0.967286 | 0.000298163 | 0.542135 | 353.581 | 0.140973    | 0.636819    | 1.211625    |
| nca_distances, with pca 3, 975, fa  | 0.898152 | 0.000317816 | 0.561191 | 422.739 | 0.133056    | 0.611893    | 1.061746    |
| nca_distances, with pca 3, 1000, fa | 0.760848 | 0.000327914 | 0.592425 | 689.994 | 0.0994571   | 0.705266    | 1.025362    |

El mejor resultado, en promedio, se dio con 900 componentes y fue disminuyendo a medida que aumentaba la cantidad de componentes, quizas probar con menos en necesario para verificar que ocurre. El mejor resultado individual se dio con 950 componentes, alcanzando un d' de 1.21

### Decimotercer experimento

Se realizaron mas pruebas para verificar los mejores resultado que se llevaban actualmente

Parametros:

- PCA: 3
- `n_components` 950, 975, 1000 (10 veces cada uno)
- Métricas: NCA

| method                          | d_prime | FMR         | FNMR     | time    | std_d_prime | min_d_prime | max_d_prime |
| ------------------------------- | ------- | ----------- | -------- | ------- | ----------- | ----------- | ----------- |
| nca_distances, with pca 3, 950  | 1.03911 | 0.000304459 | 0.545957 | 369.209 | 0.111966    | 0.750728    | 1.214685    |
| nca_distances, with pca 3, 975  | 0.96685 | 0.000324022 | 0.561373 | 379.14  | 0.126734    | 0.783614    | 1.179884    |
| nca_distances, with pca 3, 1000 | 1.01837 | 0.000285798 | 0.531473 | 395.852 | 0.088746    | 0.880769    | 1.145598    |


## Conclusiones

### Fase de training
En la fase de training se realizan los experimentos anteriores, donde se observa principalmente que:

#### Lo que funciona
- NCA funciona: el mejor resultado es de 1.03.
- PCA funciona si se usa con whitening.
- Utilizar 900 features de PCA funciona.
- LBP funciona con 8x8 ventanas.

#### Lo que no funciona
- RCA no funciona.
- Utilizar muy pocas features no funciona.
- PCA sin whitening no funciona.
- No usar PCA tampoco funciona: demasiadas features.


#### Justificación en resultados

| method                                            |     d_prime |         FMR |       FNMR |       time |   std_d_prime |   min_d_prime |   max_d_prime |
|---------------------------------------------------|-------------|-------------|------------|------------|---------------|---------------|---------------|
| nca_distances, with pca 3, 975                    | 1.10109     | 0.000292353 | 0.511958   |  356.2     |   0           |   1.10109     |   1.10109     |
| nca_distances, with pca 3, 950                    | 1.058       | 0.000303417 | 0.543455   |  356.874   |   0.130123    |   0.861727    |   1.21094     |
| nca_distances, with pca 3, 660                    | 1.05032     | 0.000302409 | 0.642893   |  384.343   |   0           |   1.05032     |   1.05032     |
| nca_distances, with pca 3, 680                    | 1.0291      | 0.000265845 | 0.607324   |  365.943   |   0           |   1.0291      |   1.0291      |
| nca_distances, with pca 3, 720                    | 1.01494     | 0.000253885 | 0.54899




## Referencias

- Primera referencia acerca de metric learning: https://en.wikipedia.org/wiki/Similarity_learning#Metric_learning
- Librería: https://metric-learn.github.io/metric-learn/metric_learn.mmc.html
- Paper de referencia en la librería, sección de Mahalanobis: https://papers.nips.cc/paper/2164-distance-metric-learning-with-application-to-clustering-with-side-information.pdf
- Dejo también esta otra implementación a mano (no he revisado si funciona o no): https://www.machinelearningplus.com/statistics/mahalanobis-distance/
