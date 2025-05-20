from modelo_autores import Autor, Libros, engine
from sqlalchemy.orm import sessionmaker

#crear sesión
Session = sessionmaker(bind=engine)
Session = Session()

#nombre del autor a buscar
nombre_autor = "Gabriel Garcia Márquez"

#buscar autor por nombre
autor = session.query(Autor).filter(Autor.nombre == nombre_autor).first()

if autor:
    print(f"/nLibros de {autor.nombre}:'n")