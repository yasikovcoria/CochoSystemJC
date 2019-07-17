Imports System.Data
Imports FirmaSAT
Imports System.IO
Imports timbradoCocho.mx.com.expidetufactura

Public Class factura
    Inherits System.Web.UI.Page
    Public objetoClases As clases = New clases
    Public mensajeError As String = ""
    Public IdEmpresa As String = ""
    Public cadenaTitulo As String = "EMISION DE FACTURAS"
    Public Function fnCargaRecibo(ByVal TipoFolio As String) As Boolean
        Dim InstrSQL As String = ""
        Dim retornoRecibo As DataView

        InstrSQL = "SELECT dbo.fnConsecutivoFactura(" + TipoFolio + ") as NumeroRecibo"
        retornoRecibo = objetoClases.fnRegresaTabla(InstrSQL, "Consecutivo")
        If retornoRecibo.Count <> 0 Then

            Response.Write("<script>")
            Response.Write("try{parent.document.getElementById('numeroReciboM').setAttribute('value','" + retornoRecibo(0)("NumeroRecibo").ToString + "'); ")
            Response.Write("}catch(ex){parent.alerta(ex.message); parent.document.getElementById('numeroReciboM').setAttribute('value','" + retornoRecibo(0)("NumeroRecibo").ToString + "'); } ")
            Response.Write("</script>")
            'Response.Write("<script> parent.document.getElementById('numeroReciboM').value = '" + retornoRecibo(0)("NumeroRecibo").ToString + "'; </script>")
        End If
        Return fnCargaRecibo
    End Function



    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Response.Write("<script>window.parent.document.getElementById('tituloModulo').innerText='" + cadenaTitulo + "';</script>")

        Dim tipoFolio As String = "", numeroReciboM As String = "", idClienteM As String = ""
        Dim cantidad As String = "", descripcion As String = "", precio As String = "", importe As String = ""
        'OPCIONES SAT   
        Dim retorno As String = ""
        Dim accion As String = HttpContext.Current.Request.Form("accion")
        Dim totalElemento As String = HttpContext.Current.Request.Form("totalFacturaM")
        Dim FormaPagoSAT As String = ""
        FormaPagoSAT = HttpContext.Current.Request.Form("formaPagoM")
        Dim MetodoPagoSAT As String = ""
        MetodoPagoSAT = HttpContext.Current.Request.Form("metodoPagoM")
        Dim CondicionPagoSAT As String = ""
        CondicionPagoSAT = HttpContext.Current.Request.Form("condicionPagoM")
        Dim CuentaPago As String = ""
        CuentaPago = HttpContext.Current.Request.Form("numeroCtaM")
        tipoFolio = HttpContext.Current.Request.Form("tipoFolioM")

        If accion = "consecutivoRecibo" Then
            Call fnCargaRecibo(tipoFolio)
        End If

        If tipoFolio = "100" Then
            IdEmpresa = "JACQ14"
        Else
            IdEmpresa = "CDLC14"
        End If

        If accion = "generaFactura" Then
            retorno = fnIngresaFactura(totalElemento, FormaPagoSAT, MetodoPagoSAT, CondicionPagoSAT, CuentaPago)
        End If

        Dim Reporte As String = "", retornoReporte As String = ""

        If accion = "factura" Then
            If IdEmpresa = "JACQ14" Then
                Reporte = "../reportes/reciboCFDI3.3.rpt"
            Else
                Reporte = "../reportes/reciboCFDI2.rpt"
            End If


            Dim InstrSQL As String = ""
            Dim InstrSQL2 As String = ""
            InstrSQL2 = "EXEC dbo.spReciboDigitalConcepto '" + HttpContext.Current.Request.Form("idEmpresa") + "','" + HttpContext.Current.Request.Form("idFactura") + "','" + HttpContext.Current.Request.Form("FolioElectronico") + "',1"
            InstrSQL = "EXEC dbo.spReciboDigitalCFDI '" + HttpContext.Current.Request.Form("idEmpresa") + "','" + HttpContext.Current.Request.Form("FolioElectronico") + "','" + HttpContext.Current.Request.Form("idFactura") + "',99"
            retornoReporte = objetoClases.fnGeneraReporte(Reporte, IdEmpresa + HttpContext.Current.Request("idFactura"), InstrSQL, InstrSQL2)

            'Response.Write(retornoReporte)
            'Response.End()

            HttpContext.Current.Response.Redirect(retornoReporte)
        End If


    End Sub
    Public Function fnIngresaFactura(ByVal totalElemento As String, ByVal FormaPagoSAT As String, ByVal MetodoPagoSAT As String, ByVal CondicionPagoSAT As String, ByVal CuentaPago As String) As Boolean

        Dim i As Integer
        Dim SqlConnection As System.Data.SqlClient.SqlConnection
        Dim SqlTransaction As System.Data.SqlClient.SqlTransaction
        Dim SQLCommand As System.Data.SqlClient.SqlCommand


        Dim DataAdapter As System.Data.SqlClient.SqlDataAdapter
        Dim DataView As New System.Data.DataView
        Dim DataSet As New System.Data.DataSet

        Dim InstrSQL As String = ""
        Dim errorCodigo As Boolean = False
        Dim mensajeError As String = ""
        Dim mensaje As String = ""
        Dim retorno As Boolean = False
        Dim DescripcionFactura As String = ""

        If totalElemento <> "" Then
            Try
                SqlConnection = New System.Data.SqlClient.SqlConnection(objetoClases.cadenaDB())
                SqlConnection.Open()
                SqlTransaction = SqlConnection.BeginTransaction()
                Dim claveImpuesto As String = ""

                For i = 0 To Integer.Parse(totalElemento) - 1

                    If Request.Form("descripcionFactura" + i.ToString) = "" Then
                        DescripcionFactura = Request.Form("nombredescripcionFactura" + i.ToString)
                    Else
                        DescripcionFactura = Request.Form("descripcionFactura" + i.ToString)
                    End If
                    claveImpuesto = objetoClases.fnRetornaValor(HttpContext.Current.Request.Form("claveImpuestoFactura" + i.ToString), "-", 2)

                    InstrSQL = "EXEC dbo.spPagoFactura '" + HttpContext.Current.Request.Form("numeroReciboM") + "','" + IdEmpresa + "','" + HttpContext.Current.Request.Form("cantidadFactura" + i.ToString) + "','" + HttpContext.Current.Request.Form("idUnidadFactura" + i.ToString) + "','" + DescripcionFactura + "','" + HttpContext.Current.Request.Form("precioFactura" + i.ToString) + "','" + HttpContext.Current.Request.Form("importeFactura" + i.ToString) + "','" + HttpContext.Current.Request.Form("ivaM") + "','" + HttpContext.Current.Request.Form("totalFacM") + "','" + HttpContext.Current.Request.Form("tipoFolioM") + "','" + HttpContext.Current.Request.Form("subTotalM") + "','" + HttpContext.Current.Request.Form("IdclienteM") + "','" + HttpContext.Current.Request.Form("ivaRetM") + "','" + HttpContext.Current.Request.Form("isrRetM") + "','" + HttpContext.Current.Request.Form("ret5M") + "','" + HttpContext.Current.Request.Form("importeImpuestoFactura" + i.ToString) + "','" + claveImpuesto + "','" + HttpContext.Current.Request.Form("claveSATFactura" + i.ToString) + "','" + HttpContext.Current.Request.Form("idUnidadFactura" + i.ToString) + "',1"
                    Response.Write(InstrSQL)

                    SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                    SQLCommand.Transaction = SqlTransaction
                    SQLCommand.ExecuteNonQuery()
                Next
                Dim totalRelacionCFDI As Integer = 0
                totalRelacionCFDI = Integer.Parse(HttpContext.Current.Request.Form("totalCFDIM"))

                For iRelacion = 0 To totalRelacionCFDI - 1
                    InstrSQL = "EXEC dbo.spRelacionCFDI '" + IdEmpresa + "','" + HttpContext.Current.Request.Form("tipoRelacionM") + "','" + HttpContext.Current.Request.Form("timbreFiscalCFDI" + iRelacion.ToString) + "','" + HttpContext.Current.Request.Form("numeroReciboM") + "',1 "
                    Response.Write(InstrSQL)
                    SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                    SQLCommand.Transaction = SqlTransaction
                    SQLCommand.ExecuteNonQuery()
                Next
                Dim fechaFactura As Object, fechaFacturaSAT As String, fechaFacturaSistema As String
                fechaFactura = Now
                fechaFacturaSAT = objetoClases.fnFormatoFecha(fechaFactura, "ymd").Replace("/", "-") + "T" + objetoClases.fnFormatoFecha(fechaFactura, "time")
                fechaFacturaSistema = objetoClases.fnFormatoFecha(fechaFactura, "dmy") + " " + objetoClases.fnFormatoFecha(fechaFactura, "time")


                InstrSQL = " EXEC dbo.spPagoFacturaDigital '" + IdEmpresa + "|" + Request.Form("porCobrarM") + "|" + Request.Form("conDireccionM") + "','" + HttpContext.Current.Request.Form("numeroReciboM") + "','" + FormaPagoSAT + "','" + MetodoPagoSAT + "','" + CondicionPagoSAT + "','" + CuentaPago + "','" + HttpContext.Current.Request.Form("IdclienteM") + "','" + fechaFacturaSistema + "',1"
                Response.Write(InstrSQL)
                SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                SQLCommand.Transaction = SqlTransaction
                SQLCommand.ExecuteNonQuery()


                Dim tieneComplementoIedu As String = ""
                tieneComplementoIedu = Request.Form("complementoM")

                If tieneComplementoIedu = "1" Then
                    InstrSQL = "EXEC dbo.spAgregaComplemento '" + IdEmpresa + "|" + Request.Form("numeroReciboM") + "|" + Request.Form("nombreAlumnoM") + "','" + Request.Form("curpAlumnoM") + "','" + Request.Form("nivelAlumnoM") + "','" + Request.Form("claveCentroAlumnoM") + "','" + Request.Form("claveCentroAlumnoM") + "','" + Request.Form("rfcPagoAlumnoM") + "' "
                    SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                    SQLCommand.Transaction = SqlTransaction
                    SQLCommand.ExecuteNonQuery()
                    Response.Write(InstrSQL)
                End If


                InstrSQL = " EXEC dbo.spGeneraXMLV3 '" + HttpContext.Current.Request.Form("tipoFolioM") + "', '" + HttpContext.Current.Request.Form("numeroReciboM") + "'"
                Response.Write(InstrSQL)
                SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                SQLCommand.Transaction = SqlTransaction

                DataAdapter = New System.Data.SqlClient.SqlDataAdapter(SQLCommand)
                DataAdapter.Fill(DataSet, "tablaXML")
                DataView = DataSet.Tables("tablaXML").DefaultView
                Dim cadenaXML As String = ""

                'Response.End()




                Dim claseSello As New selloBase64(), base64Certificado As String = "", cadenaOriginalXML As String = "", selloXmla As String = ""

                Dim rutaUpload As String = Server.MapPath("../../upload/")
                Dim respuestaPrueba As mx.com.expidetufactura.pruebastimbrado.respuestaTimbrado
                Dim respuestaReal As mx.com.expidetufactura.timbradodp.respuestaTimbrado


                If DataView.Count <> 0 Then
                    cadenaXML = DataView(0)("xmlPreTimbrado")
                    base64Certificado = claseSello.fnBase64Cert(rutaUpload + "SelloDigital/" + DataView(0)("Certificado"))
                    cadenaXML = Replace(cadenaXML, "Certificado=""""", "Certificado=""" + base64Certificado + """")


                    Dim streamWriter As System.IO.StreamWriter = System.IO.File.CreateText(rutaUpload + "XML/" + HttpContext.Current.Request.Form("numeroReciboM") + ".xml")
                    streamWriter.WriteLine(cadenaXML)
                    StreamWriter.Close()
                    streamWriter = Nothing
                    cadenaOriginalXML = claseSello.fnObtenCadena(rutaUpload + "XML/" + HttpContext.Current.Request.Form("numeroReciboM") + ".xml", "http://www.sat.gob.mx/sitio_internet/cfd/3/cadenaoriginal_3_3/cadenaoriginal_3_3.xslt", "")



                    'cadenaOriginalXML = "||3.3|A|123ABC|2017-05-01T01:23:59|02|40001000000300000337|CONDICIONES|1000|0.00|MXN|1.0|1500|I|PUE|45079|Az123|02|ED1752FE-E865-4FF2-BFE1-0F552E770DC9|AAA010101AAA|Esta es una demostración|622|BASJ600902KL9|Juanito Bananas De la Sierra|MEX|987654321|G03|01010101|00001|1.5|C81|TONELADA|ACERO|1500000|2250000|2250000|002|Tasa|1.600000|360000|2250000|001|Tasa|0.300000|247500|51888|95141904|00002|1.6|WEE|TONELADA|ALUMINIO|1500|2400|2400|002|Tasa|1.600000|384|2400|001|Tasa|0.300000|264|15 48 4567 6001234|84101604|00003|1.7|G66|TONELADA|ZAMAC|10000|17000|0|17000|002|Tasa|1.600000|2720|17000|001|Tasa|0.300000|1870|25201513|055155|1.0|UNIDAD|PARTE EJEMPLO|1.00|1.00|15 48 4567 6001235|001|247000|003|500|247500|002|Tasa|1.600000|360000|360000||"

                    'Response.Write(cadenaOriginalXML)
                    'Response.End()

                    'Response.Write(rutaUpload + "SelloDigital\" + DataView(0)("Llave") + "--------" + cadenaOriginalXML)

                    'selloXmla = claseSello.fnSelloCochoCFDI(DataView(0)("PassLlave"), rutaUpload + "SelloDigital/" + DataView(0)("Llave"), cadenaOriginalXML)
                    'selloXmla = claseSello.fnSelloCochoCFDI("12345678a", rutaUpload + "SelloDigital/" + DataView(0)("Llave"), cadenaOriginalXML)
                    selloXmla = claseSello.fnSello33(DataView(0)("PassLlave"), objetoClases.fnFileToByteArray(Replace(rutaUpload + "SelloDigital\" + DataView(0)("Llave"), ".key", ".pfx")), cadenaOriginalXML)



                    cadenaXML = Replace(cadenaXML, "Sello=""""", "Sello=""" + selloXmla + """")

                    Dim streamWriter2 As System.IO.StreamWriter = System.IO.File.CreateText(rutaUpload + "XML/" + HttpContext.Current.Request.Form("numeroReciboM") + "_2.xml")
                    streamWriter2.WriteLine(cadenaXML)
                    streamWriter2.Close()
                    streamWriter2 = Nothing

                    Dim archivoXMLFirmado As String = rutaUpload + "XML/" + HttpContext.Current.Request.Form("numeroReciboM") + "_2.xml"





                    Dim claseXpide As timbradoExpide = New timbradoExpide()

                    Dim archivoTimbreRespuesta As String = rutaUpload + "XML\" + HttpContext.Current.Request.Form("numeroReciboM") + "Timbre.xml"
                    Dim codigoRespuesta As String = ""
                    Dim timbreUUID As String = ""

                    If 10 = 1 Then
                        claseXpide.passwordWeb = "12345678a"
                        claseXpide.usuarioWeb = "pruebas"

                        respuestaPrueba = claseXpide.fnTimbraPrueba(objetoClases.fnFileToByteArray(archivoXMLFirmado))
                        archivoTimbreRespuesta = respuestaPrueba.timbre
                        timbreUUID = respuestaPrueba.uuid
                        codigoRespuesta = respuestaPrueba.codigo
                        mensajeError = respuestaPrueba.mensaje
                    Else
                        claseXpide.passwordWeb = DataView(0)("PassWebService")
                        claseXpide.usuarioWeb = DataView(0)("UsuarioWebService")
                        respuestaReal = claseXpide.fnTimbraR(objetoClases.fnFileToByteArray(archivoXMLFirmado))
                        archivoTimbreRespuesta = respuestaReal.timbre
                        timbreUUID = respuestaReal.uuid
                        codigoRespuesta = respuestaReal.codigo
                        mensajeError = respuestaReal.mensaje
                    End If




                    Response.Write("aSDasddasd=" + mensajeError)
                    'Response.End()


                    Dim archivoTimbreRespuesta2 As String = rutaUpload + "XML\" + timbreUUID + ".xml"
                    Dim streamWriter3 As System.IO.StreamWriter = System.IO.File.CreateText(archivoTimbreRespuesta2)
                    streamWriter3.WriteLine(archivoTimbreRespuesta)
                    streamWriter3.Close()


                    Dim cadenaOriginalRespuesta As String = ""
                    cadenaOriginalRespuesta = claseSello.fnObtenCadena(rutaUpload + "XML\" + timbreUUID + ".xml", rutaUpload + "archivoSAT\cadenaoriginal_3_3.xslt", "")
                    'creamos documentoXML para leer la informacion del timbreFiscal
                    Dim documentoXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
                    Dim nodoTimbre As System.Xml.XmlNodeList, selloSat As String = "", certificadoDigital As String = ""

                    documentoXML.Load(rutaUpload + "XML\" + timbreUUID + ".xml")
                    nodoTimbre = documentoXML.GetElementsByTagName("tfd:TimbreFiscalDigital")
                    Dim atributosTimbre As System.Xml.XmlAttributeCollection
                    atributosTimbre = nodoTimbre.Item(0).Attributes
                    Dim UUID As String = "", FechaTimbrado As String = "", SelloCFD As String = "", NoCertificadoSAT As String = ""

                    For iTimbre = 0 To atributosTimbre.Count - 1
                        If atributosTimbre.Item(iTimbre).Name = "UUID" Then
                            UUID = atributosTimbre.Item(iTimbre).Value
                        End If

                        If atributosTimbre.Item(iTimbre).Name = "NoCertificadoSAT" Then
                            NoCertificadoSAT = atributosTimbre.Item(iTimbre).Value
                        End If
                        If atributosTimbre.Item(iTimbre).Name = "SelloSAT" Then
                            selloSat = atributosTimbre.Item(iTimbre).Value
                        End If

                    Next


                    InstrSQL = "UPDATE PagoFacturaDigital SET PFDigCadenaOriginal= @PFDigCadenaOriginal,PFDigSelloDigital = @PFDigSelloDigital ,PFDigXMLTimbrado = @PFDigXMLTimbrado,PFDigXML = @PFDigXML,PFDigCertificadoDigital=@PFDigCertificadoDigital WHERE PFDigIdFactura = " + HttpContext.Current.Request.Form("numeroReciboM") + " AND PFDigIdEmpresa='" + IdEmpresa + "'"
                    SQLCommand = New SqlClient.SqlCommand("SELECT * FROM PagoFacturaDigital WHERE PFDigIdFactura = " + HttpContext.Current.Request.Form("numeroReciboM") + " AND PFDigIdEmpresa='" + IdEmpresa + "'", SqlConnection)
                    SQLCommand.Transaction = SqlTransaction

                    DataAdapter = New System.Data.SqlClient.SqlDataAdapter(SQLCommand)
                    DataAdapter.Fill(DataSet, "PagoFacturaDigital")
                    Dim dt As System.Data.DataTable = DataSet.Tables("PagoFacturaDigital")
                    dt.Rows(0)("PFDigCadenaOriginal") = cadenaOriginalRespuesta
                    dt.Rows(0)("PFDigSelloDigital") = selloSat
                    dt.Rows(0)("PFDigXMLTimbrado") = archivoTimbreRespuesta
                    dt.Rows(0)("PFDigXML") = cadenaXML
                    dt.Rows(0)("PFDigCertificadoDigital") = NoCertificadoSAT

                    SQLCommand = New SqlClient.SqlCommand(InstrSQL, SqlConnection)
                    SQLCommand.Transaction = SqlTransaction


                    SQLCommand.Parameters.Add("@PFDigCadenaOriginal",
                            SqlDbType.Text, 80000, "PFDigCadenaOriginal")
                    SQLCommand.Parameters.Add("@PFDigSelloDigital",
                               SqlDbType.Text, 80000, "PFDigSelloDigital")
                    SQLCommand.Parameters.Add("@PFDigXMLTimbrado",
                               SqlDbType.Text, 5000000, "PFDigXMLTimbrado")
                    SQLCommand.Parameters.Add("@PFDigXML",
                               SqlDbType.Text, 5000000, "PFDigXML")
                    SQLCommand.Parameters.Add("@PFDigCertificadoDigital",
                               SqlDbType.Text, 80000, "PFDigCertificadoDigital")
                    DataAdapter.UpdateCommand = SQLCommand
                    DataAdapter.Update(DataSet, "PagoFacturaDigital")
                    retorno = True

                End If



                'Falta hacer commit a las instruccionesSQL y guardar xmlnoTimbrado y xmlTimbrado DB


                If retorno = True Then
                    errorCodigo = False
                    SqlTransaction.Commit()
                    mensajeError = ""
                    mensaje = "La factura se genero con exito"
                    Response.Write("<s" + "cript>parent.alerta('" + mensaje + "')</s" + "cript>")
                    Response.Write("<script> ")
                    Response.Write(" parent.fnImprimeRecibo('" + IdEmpresa + "','" + Request.Form("numeroReciboM") + "','" + Request.Form("tipoFolioM") + "'); ")
                    Response.Write(" parent.fnLimpiaTabla('bodyFacturaM','totalFacturaM');")
                    Response.Write(" parent.fnLimpiaFactura(); ")
                    Response.Write(" </script>")
                    SqlConnection.Close()
                Else
                    SqlTransaction.Rollback()


                End If

            Catch ex As Exception
                SqlTransaction.Rollback()
                mensajeError = ex.Message.Replace("'", "\'")
                mensajeError = mensajeError
                Response.Write("<s" + "cript>parent.alerta('" + mensajeError + "')</s" + "cript>")
            End Try

        End If

        Return retorno
    End Function



End Class