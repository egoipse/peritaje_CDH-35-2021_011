# Peritaje para CDH-35-2021/011 Caso Vega González y otros Vs. Chile

Este repositorio contiene los scripts en `R` que generan los datos y el informe final de un peritaje para la causa CDH-35-2021/011 alegada ante la Corte Interamericana de Derechos Humanos. El pertiaje es un análisis de minería de texto de las sentencias de la Corte Suprema de Chile en casos judiciales relacionados con violaciones sistemáticas a los Derechos Humanos cometidas por la dictadura cívico-militar de 1973 a 1990. Su objetivo es identificar si existen diferencias entre las sentencias que apelan a la media prescripción y las que no apelan a ella.

En la carpeta `src` se encuentran los códigos que importan, procesan, limpian y preparan los textos de las sentencias para la minería.

Los archivos de las sentencias debían estar la carpeta `docs`. Debido a su gran cantidad y al limitado espacio de almacenamiento de github, no se encuentran en el presente repositorio. Se pueden descargar del [siguiente enlace](https://www.dropbox.com/sh/cwfkr16ocx12j55/AAAiLjUMcz0ktduiVPPYR0iAa?dl=1). Si este repositorio es clonado, deben descargarse y guardarse en la carpeta `docs/Causas` para que los scripts funcionen.

El reporte final se genera con RMarkdown a través del scritp informe_final.RMD que se encuentra en la carpeta `reports`.

Quedan liberados los scripts y los archivos con las sentencias con el propósito de hacer posible tanto la auditoría y reproducción del proceso de generación de los resultados del reporte. Se permite su uso bajo los términos de la licenceia Creative Commons 4.0 NonCommercial - Attribution - ShareAlike.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />Esta obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Licencia Creative Commons Atribución-NoComercial-CompartirIgual 4.0 Internacional</a>.

