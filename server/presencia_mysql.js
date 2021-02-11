const express = require("express");
const mysql = require("mysql2/promise");

let db = null;
const app = express();
const port = 8001;

app.use(express.json());

app.post('/registrar', async(req, res, next)=>{
  const values = req.body.values;
  console.debug("INSERT INTO presencia (idpersona, idpdt, idpda, inicio,fin, idtlogin, idtlogout, observaciones, DATA, TIME,USER) VALUES (" + values + ");");

  await db.query("INSERT INTO presencia (idpersona, idpdt, idpda, inicio,fin, idtlogin, idtlogout, observaciones, DATA, TIME,USER) VALUES (" + values + ");");

  res.json({status:"OK"});
  next();
});

app.post('/cerrar_parte', async(req, res, next)=>{
  const values = req.body.values;
  console.debug(values);

  await db.query(values);

  res.json({status:"OK"});
  next();
});

app.get('/personas/:puntoAcceso', async (req, res, next) => {
  console.info('Id punto acceso: ' + req.params.puntoAcceso);
  //const [rows] = await db.query("SELECT id,idtarjeta,descri,pwd FROM persona WHERE fecbaja ='' OR fecbaja IS null ORDER BY id;");
  const [rows] = await db.query("SELECT p.id,p.idtarjeta,p.descri,p.pwd " +
                                "FROM persona p LEFT JOIN persona_pdt pp ON pp.idpersona = p.id " +
                                "LEFT JOIN puesto_trabajo pt ON pt.id = pp.idpdt " +
                                "LEFT JOIN pt_ptoacc ON pt_ptoacc.idpdt = pt.id " +
                                "LEFT JOIN punto_acceso pa ON pt_ptoacc.idpto = pa.id " +
                                "WHERE (p.fecbaja ='' OR p.fecbaja IS NULL) AND pa.id = " + req.params.puntoAcceso + " " +
                                "GROUP BY p.id " +
                                "ORDER BY p.descri;");
  console.info('Consulta ejecutada');
  res.json(rows);
  console.info('Res');
  next();
  console.info('next'); 
});

app.get('/parte_activo/:userID', async (req, res, next) => {        
 const [rows] = await db.query("SELECT id FROM presencia WHERE idpersona = " + req.params.userID + " AND (fin ='' OR fin IS null);");
 console.debug(req.params.userID);
 res.json(rows); 
 next();
});

app.use((req, res, next) => {
  const error = new Error("Not found");
  error.status = 404;
  next(error);
});

// error handler middleware
app.use((error, req, res, next) => {
    res.status(error.status || 500).send({
      error: {
        status: error.status || 500,
        message: error.message || 'Internal Server Error',
      },
    });
  });


async function main(){
  db = await mysql.createConnection({
    host:"192.168.123.229",
    user: "aspdev",
    password: "11972702",
    database: "eadeptlito"
  });

  const server = app.listen(port, () => console.log(`App listening on port: ${port}`));
  server.keepAliveTimeout = 61*1000;
  server.headersTimeout = 65 * 1000;
 
  console.info('Server status: ' + server.status);
}

main();
