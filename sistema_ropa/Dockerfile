# Tomcat 10
FROM tomcat:10.1.12-jdk17

# Elimina los archivos por defecto
RUN rm -rf /usr/local/tomcat/webapps/*

# Copia tu WAR
COPY target/sistema_ropa-0.0.1.war /usr/local/tomcat/webapps/sistema_ropa.war

# Expone el puerto 8081
EXPOSE 8081

CMD ["catalina.sh", "run"]