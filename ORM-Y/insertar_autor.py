from modelo_autores import Autor, Libro, Socio, Base, engine
from sqlalchemy.orm import sessionmaker
from datetime import date

# Crear sesión
Session = sessionmaker(bind=engine)
session = Session()

# --- Autores ---
autor1 = Autor(nombre="Gabriel García Márquez", nacionalidad="Colombiana", fecha_nacimiento=date(1927, 3, 6))
autor2 = Autor(nombre="Jorge Luis Borges", nacionalidad="Argentina", fecha_nacimiento=date(1899, 8, 24))
autor3 = Autor(nombre="Julio Cortázar", nacionalidad="Argentina", fecha_nacimiento=date(1914, 8, 26))

session.add_all([autor1, autor2, autor3])
session.commit()

# --- Libros ---
libro1 = Libro(
    titulo="Cien años de soledad",
    autor_id=autor1.id,
    isbn="978-84-376-0494-7",
    genero="Realismo mágico",
    anio_publicacion=1967,
    disponible=True,
    tipo="físico"
)
libro2 = Libro(
    titulo="El Aleph",
    autor_id=autor2.id,
    isbn="978-84-206-3892-6",
    genero="Cuento fantástico",
    anio_publicacion=1949,
    disponible=True,
    tipo="físico"
)
libro3 = Libro(
    titulo="Rayuela",
    autor_id=autor3.id,
    isbn="978-84-264-1647-4",
    genero="Novela experimental",
    anio_publicacion=1963,
    disponible=True,
    tipo="digital"
)
libro4 = Libro(
    titulo="Crónica de una muerte anunciada",
    autor_id=autor1.id,
    isbn="978-84-376-0496-1",
    genero="Novela corta",
    anio_publicacion=1981,
    disponible=True,
    tipo="físico"
)
libro5 = Libro(
    titulo="Ficciones",
    autor_id=autor2.id,
    isbn="978-84-206-3890-2",
    genero="Cuento filosófico",
    anio_publicacion=1944,
    disponible=True,
    tipo="digital"
)

session.add_all([libro1, libro2, libro3, libro4, libro5])
session.commit()

# --- Socios ---
socio1 = Socio(nombre="Ana", apellido="González", direccion="Av. Rivadavia 1234")
socio2 = Socio(nombre="Martín", apellido="Pérez", direccion="Calle 9 Nº 456")
socio3 = Socio(nombre="Lucía", apellido="Fernández", direccion="San Martín 785")
socio4 = Socio(nombre="Tomás", apellido="López", direccion="Bv. Oroño 2020")

session.add_all([socio1, socio2, socio3, socio4])
session.commit()

print("Datos insertados correctamente.")

session.close()
