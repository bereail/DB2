from sqlalchemy import Column, Integer, String, Date, Boolean, ForeignKey, create_engine
from sqlalchemy.orm import declarative_base, relationship, sessionmaker

Base = declarative_base()

# Modelo Autor
class Autor(Base):
    __tablename__ = 'autores'

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String, nullable=False)
    nacionalidad = Column(String)
    fecha_nacimiento = Column(Date)

    libros = relationship('Libro', back_populates='autor')

# Modelo Libro
class Libro(Base):
    __tablename__ = 'libros'

    id = Column(Integer, primary_key=True, autoincrement=True)
    titulo = Column(String, nullable=False)
    autor_id = Column(Integer, ForeignKey('autores.id'), nullable=False)
    isbn = Column(String, unique=True)
    genero = Column(String)
    anio_publicacion = Column(Integer)
    disponible = Column(Boolean, default=True)
    tipo = Column(String)  # 'fÃ­sico' o 'digital'

    autor = relationship('Autor', back_populates='libros')
    prestamos = relationship('Prestamo', back_populates='libro')

# Modelo Socio
class Socio(Base):
    __tablename__ = 'socios'

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    direccion = Column(String)

    prestamos = relationship('Prestamo', back_populates='socio')

# Modelo Prestamo
class Prestamo(Base):
    __tablename__ = 'prestamos'

    libro_id = Column(Integer, ForeignKey('libros.id'), primary_key=True)
    socio_id = Column(Integer, ForeignKey('socios.id'), primary_key=True)
    fecha_prestamo = Column(Date, primary_key=True)
    fecha_devolucion = Column(Date, nullable=False)
    fecha_devuelto = Column(Date)

    libro = relationship('Libro', back_populates='prestamos')
    socio = relationship('Socio', back_populates='prestamos')

# Crear la base de datos
engine = create_engine('sqlite:///biblioteca.db', echo=True)
Base.metadata.create_all(engine)
