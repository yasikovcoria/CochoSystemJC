<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<!--#include file="../../funciones/mis_funciones.asp" -->
<link href="../../CSS/dynamicCombo.css" rel="stylesheet" type="text/css"> 
<%  
 pathImages = "../../images/"
 accion = Request.Form("accion")
 Catalogo = request("Catalogo")
 pagina = request("pagina")
 cmbTextPadre = request("cmbTextPadre")
 cmbIdPadre = request("cmbIdPadre")
 alto = request("alto")
 ancho = request("ancho")
 iPageCount = 0
 paginaActual = 0
 MostrarFooter = "0"
 auxAnchoMostrarFooter = 0
 auxAltoMostrarFooter = 0
 IF cmbTextPadre = "" THEN cmbTextPadre = "procesado"
 IF cmbIdPadre = "" THEN cmbIdPadre = "procesado"
 if ancho = "" Then ancho = 500
 if alto = "" Then alto = 100
 
 Call ABREDB2(DBMun,Application("DATABASEMUN"))
 
 InstrSQL = "EXEC spObtieneCatalogo '" & Catalogo & "','" & Session("idEmpresa")& "'" 'Busca el cat�logo a procesar
 Call AbreRS2(RSInstruccion,DBMun,InstrSQL)
 InstrSQL = ""
 Condicion = ""
 If RSInstruccion.EOF <> TRUE THEN
  PaginacionTop = ""
  'Verifica si se existe condici�n de impresi�n de un tope de registros
  IF RSInstruccion.Fields("Paginacion") <> "" THEN PaginacionTop = " TOP " & RSInstruccion.Fields("Paginacion") 
  'Se construye la instrucci�n principal de todos los registros de una consulta (sin condiciones).
  InstrSQL = "SELECT " & PaginacionTop & RSInstruccion.Fields("CampoClave") & " AS ID," _
   & RSInstruccion.Fields("CampoMostrar") & " AS Nombre FROM " & RSInstruccion.Fields("Tabla")
  MostrarFooter =  Request.Form("showFooter") 'Verifica si se va a imprimir el pie del cat�logo (paginaci�n)
  If MostrarFooter = "0" THEN 
   auxAnchoMostrarFooter = 0
   auxAltoMostrarFooter = 20
  End If
  'Entra a esta condici�n s�lo si el campo de filtro contiene informaci�n o es diferente a la palabra clave "all"
  If Request.Form("CampoMostrar") <> "" AND Request.Form("CampoMostrar") <> "all" THEN 
   'invoca a la funci�n que se encarga de reemplazar likes.  Aplicar� en d�nde encuentre espacios
   Condicion = GetCriterio(RSInstruccion.Fields("CampoMostrar"),Replace(Request.Form("CampoMostrar")," ","+"))
   Condicion = " " & Condicion & " "
  End If
  OrderBy = " ORDER BY " & RSInstruccion.Fields("OrderBy") 'Los registros se ordenaran por este campo
  NombreCatalogo = RSInstruccion.Fields("Nota") 'Es el nombre del cat�logo (no se usa actualmente)
  ASPPage = RSInstruccion.Fields("ASPPage") 'Es el link que introduzcamos en el cat�logo
 END IF
 'Verifica si el cat�logo tiene filtros referenciados a variables de session o a objetos tipo request (YA NO SE UTILIZA)
 DO WHILE RSInstruccion.EOF <> TRUE
  AuxCond = " AND "
  IF Condicion = "" THEN AuxCond = " WHERE "
  IF RSInstruccion.Fields("IdTipoObjeto") <> -1 THEN
   IF RSInstruccion.Fields("IdTipoObjeto") = 1 Then
    Condicion =Condicion & AuxCond & RSInstruccion.Fields("Campo") _
	 & " = " & RSInstruccion.Fields("CaracterConcatena") & SESSION(RSInstruccion.Fields("Parametro")) _
	 & RSInstruccion.Fields("CaracterConcatena")
   Else
    Condicion = Condicion & AuxCond & RSInstruccion.Fields("Campo") _
 	 & " = " & RSInstruccion.Fields("CaracterConcatena") & Request(RSInstruccion.Fields("Parametro")) _
	 & RSInstruccion.Fields("CaracterConcatena")
   End If
  End If   
  RSInstruccion.MoveNext
 LOOP
 
 tamarreglo=2
 j = 0
 contador = 0
 dim arreglo()
 'ARREGLO PARA SEPARAR LAS CONDICIONES ENVIADAS
 Redim arreglo(tamarreglo)
 separador = "|"
 linea = Request("condicion")
 posicion = instr(linea,separador)
 while not posicion = 0
  contador = 1
  if j = (tamarreglo-1) then
  tamarreglo=tamarreglo + 1
  redim preserve arreglo(tamarreglo)
  end if
  arreglo(j)=left(linea,posicion-1)
  linea=right(linea,len(linea)-posicion)
  j=j+1
  posicion=instr(linea,separador)
 wend
 if j > 0 then
  arreglo(j) = linea
 else
  If Request("condicion") <> "" THEN 
   arreglo(0) = Request("condicion")
   contador = 1
  End If
 End If
 
 'ARREGLO PARA SEPARAR LOS CAMPOS DE LAS CONDICIONES, DESPUES SE PROSIGE A SEPARAR EL TIPO DE CONDICI�N (=,<>,etc)
 separador = "?"
 tamarreglo = 2
 condicionY = ""
 
 If contador =1 THEN
  for z= 0 to j
   condicionX = ""
   linea = arreglo(z)
   posicion = instr(linea,separador)
   condicionY =left(linea,posicion-1)
   linea=right(linea,len(linea)-posicion)
   condicionX = linea
   linea2 = condicionX
   separador2 ="&"
   posicion2 = instr(linea2,separador2)
   condicionY = condicionY & " " & left(linea2,posicion2-1)
   linea2=right(linea2,len(linea2)-posicion2) 
   posicion2 = instr(linea2,separador2) 
   condicionZ = ""
   
   while not posicion2 = 0
    condicionZ= condicionZ & condicionY & " " & condicionZ & left(linea2,posicion2-1) & " "
    linea2=right(linea2,len(linea2)-posicion2)
    jj=jj+1
    posicion2=instr(linea2,separador2)
   wend
   
   if jj > 0  then
    condicionZ= condicionZ & condicionY & " " & linea2 & " "
   else
    if contador = 1 THEN condicionZ= condicionY & " " & linea2 & " "
   end if   
   condicionAux = ""
   if condicion <> "" Then
    condicionAux = " AND "
   else
    condicion = " WHERE "  
   End if
   condicionZ = mid(condicionZ,4,len(condicionZ))  
   arreglo(z) = condicionAux & " (" & condicionZ & ") " 
  next
 End If 
 
 If  contador =1 THEN
  for z= 0 to j
   Condicion = Condicion &  arreglo(z)
  Next
 End If
 
 CALL CierraRS(RSInstruccion)
 Response.Write "<form name=""frmComboBox"">"
 Response.Write "<div id=""layCatalogo"" style=""position:absolute;visibility:hidden;top:0px;left:0px;width:" & ancho+20+auxAnchoMostrarFooter & "px;height:" & alto-5+auxAltoMostrarFooter & "px;overflow-x:hidden;overflow-y:scroll;border: 1px solid #7499C5;"">"
'Response.Write InstrSQL & Condicion & OrderBy 'aqui
'Response.Write Request("condicion")
'InstrSQL = ""
 IF InstrSQL <> "" THEN 'S�lo entra si existe una consulta maestra
  Response.Write "<table border=""0"" class="""" width=""" & ancho & "px"" align=""center"" cellpadding=""1px"" cellspacing=""0px"">"
  Response.Write "<tbody id=""bodytable"">"
  InstrSQL = InstrSQL & Condicion & OrderBy 'Se le a�ade condici�nes y ordenamiento a la consulta maestra
  Call AbreRS2(RSCatalogo,DBMun,InstrSQL)
  Registros = RSCatalogo.RecordCount 'Se obtienen el total de registros
  tamPagina = 100
  if isnumeric(Request("paginacionX")) THEN tamPagina = CINT(Request("paginacionX")) 'Se determina el n�mero de registros por p�gina
  RSCatalogo.Pagesize = tamPagina
  RSCatalogo.CacheSize = tamPagina
  iPageCount = RSCatalogo.PageCount 'Se obtienen el tama�o de p�ginas totales
  If NOT isNumeric(pagina) THEN pagina = 1
  pagina = Cint(pagina)
  If pagina >= iPageCount Then 'Validaciones sobre el n�mero de p�gina actual
   paginaActual = iPageCount
  Else
   paginaActual = pagina
  End If
  contador = 0
  IF Registros > 0 THEN RSCatalogo.AbsolutePage = paginaActual 
  i = 0
  DO WHILE RSCatalogo.EOF <> TRUE 'Se imprimen los registros de la p�gina solicitada
   if i<tamPagina Then 'Termina si se cumple con los registros a mostrar
    Response.Write "<tr class=""ContenidoDynamicCombo"" id=""id" & i & """ name=""id" & i & """ onClick=""procesa(" & i & ");"" title=""Haga clic para pasar Par�metros"">"
    Response.Write "<td align=""center"" class=""sinbordes"" width=""1px"">&nbsp;</span></td>"
    Response.Write "<td align=""left"" class=""sinbordes""><span class=""celda_titulo"">" _
     & "<div id=""blay" & i + 0 & """>" & RSCatalogo.Fields("Nombre") & "</div></span></td>"
    Response.Write "</tr>"
    Response.Write "<div id=""alay" & i + 0 & """ style=""visibility:hidden;top:0px;position:absolute;"">" & RSCatalogo.Fields("ID") & "</div>"
   Else
    EXIT DO
   End If
   i = i + 1
   RSCatalogo.MoveNext
  LOOP
  CALL CierraRS(RSCatalogo)
  Response.Write "</tr>"
 End If
 Response.Write "</tbody></table>"
 IF Registros = 0 THEN Response.Write "<span class=""celda_titulo""><font color=""red"">No se encontrar�n registros!!!</font></span>"
 Response.Write "</div>"
 'Hiddens generales para asegurar recursividad del cat�logo
 Response.WRITE "<input name=""pagina"" id=""pagina"" type=""hidden"" value="""">"
 Response.WRITE "<input name=""catalogo"" id=""catalogo"" type=""hidden"" value=""" & Request.Form("Catalogo") & """>"
 Response.WRITE "<input name=""cmbTextPadre"" id=""cmbTextPadre"" type=""hidden"" value=""" & Request.Form("cmbTextPadre") & """>"
 Response.WRITE "<input name=""cmbIdPadre"" id=""cmbIdPadre"" type=""hidden"" value=""" & Request.Form("cmbIdPadre") & """>"
 Response.WRITE "<input name=""accion"" id=""accion"" type=""hidden"" value=""" & Request.Form("accion") & """>"
 Response.WRITE "<input name=""ancho"" id=""ancho"" type=""hidden"" value=""" & Request.Form("ancho") & """>"
 Response.WRITE "<input name=""alto"" id=""alto"" type=""hidden"" value=""" & Request.Form("alto") & """>"
 Response.WRITE "<input name=""condicion"" id=""condicion"" type=""hidden"" value=""" & Request.Form("condicion") & """>"
 Response.WRITE "<input name=""CampoMostrar"" id=""CampoMostrar"" type=""hidden"" value="""">"
 Response.WRITE "<input name=""indiceAnterior"" id=""indiceAnterior"" type=""hidden"" value="""">"
 Response.WRITE "<input name=""accionJavaScript"" id=""accionJavaScript"" type=""hidden"" value=""" & Request.Form("accionJavaScript") & """>"
 Response.WRITE "<input name=""paginacionX"" id=""paginacionX"" type=""hidden"" value=""" & Request.Form("paginacionX") & """>"
 Response.WRITE "<input name=""procesado"" id=""procesado"" type=""hidden"" value="""">"
 Response.WRITE "<input name=""showFooter"" id=""showFooter"" type=""hidden"" value=""" & Request.Form("showFooter") & """>"
 Response.WRITE "<input name=""parentMaster"" id=""parentMaster"" type=""hidden"" value=""" & Request.Form("parentMaster") & """>"
 Response.WRITE "<input name=""iFrameFather"" id=""iFrameFather"" type=""hidden"" value=""" & Request.Form("iFrameFather") & """>"
 Response.WRITE "<input name=""resizeNewIFrame"" id=""resizeNewIFrame"" type=""hidden"">"
 Response.Write "</form>"
 'S�lo entra si se solicito la impresi�n del pie del cat�logo
 IF MostrarFooter = "1" THEN
  Response.Write "<div id="""" align=""center"" style=""position:absolute;visibility:visible;top:" & alto-5
  Response.Write "px;left:0px;width:" & ancho +20 & "px;height:20px;overflow: no;"" class=""paginacion"">"
  Response.Write "<table border=""1"" class="""" width=""" & ancho +20 & "px"" align=""center"">"
  Response.Write "<tr class=""registros"">"
  imgAgregar = ""
  if ASPPage <> "" THEN imgAgregar = "<img src=""" & pathImages _
   & "comboBox/edit.gif"" border=""0"" align=""top"" title=""Haga clic para agregar, modificar o eliminar registros""" _
   & " onMouseOver=""this.src='" & pathImages & "comboBox/edit2.gif" & "';"" onMouseOut=""this.src='" & pathImages _
   & "comboBox/edit.gif" & "';"" onClick=""procesaASPCatalogue('" & Replace(ASPPage,"\","\\") & "');"">" 'Se arma el link a procesar al dar clic en la imagen a imprimir (si existe)
  strPaginaAux = ((paginaActual*tamPagina)-tamPagina+1) & "-" & ((paginaActual*tamPagina)-tamPagina)+i 
  if Registros = 0 THEN strPaginaAux = "0"
  'Imprime p�gina actual, total de registros, etc
  Response.Write "<td class=""registros"" width=""35%""><div id=""registroAct"">Registros:&nbsp;" & strPaginaAux & "/" & Registros & "</div></td>"
  Response.Write "<td class=""paginacion"" width=30%"" align=""center"">&nbsp;"
  If iPageCount >1 AND paginaActual <> 1 THEN Response.Write "&nbsp;&nbsp;<a href=""javascript:enviar(1);"" title=""Primer p�gina""><img src=""" & pathImages & "comboBox/firstpage.gif"" border=""0"" align=""middle""></a>&nbsp;" 
  If iPageCount >1 AND paginaActual > 1 THEN Response.Write "<a href=""javascript:enviar(" & paginaActual -1 & ");"" title=""P�gina anterior""><img src=""" & pathImages & "comboBox/prevpage.gif"" border=""0"" align=""middle""></a>&nbsp;"
  Response.Write "<input name=""pagina"" id=""pagina2"" type=""text"" onkeyPress=""verificaTxtPag(event,this," & paginaActual & "," & iPageCount & ");"" value=""" & paginaActual & """ maxlength=""6"" style=""width:30px;"" class=""paginacion"" title=""Ingrese un n�mero de p�gina y presione la tecla ENTER"">"
  If iPageCount >1 AND paginaActual < iPageCount THEN Response.Write "<a href=""javascript:enviar(" & paginaActual + 1 & ");"" title=""P�gina siguiente""><img src=""" & pathImages & "comboBox/nextpage.gif"" border=""0"" align=""middle"">&nbsp;</a>"
  If iPageCount >1 AND paginaActual <> iPageCount THEN Response.Write "<a href=""javascript:enviar(" & iPageCount & ");"" title=""Ultima p�gina""><img src=""" & pathImages & "comboBox/lastpage.gif"" border=""0"" align=""middle"">&nbsp;</a>"
  Response.Write "</td>"
  Response.Write "<td class=""registros"" width=""35%"" align=""right"">P�gina:&nbsp;" & paginaActual & " de " & iPageCount & "&nbsp;&nbsp;" & imgAgregar & "</td>"
  Response.Write "</tr>" 
  Response.Write "</table>"
  Response.Write "</div>"
 END IF
 'variables sobre el estatus de la p�gina actual (NO SE UTILIZA)
 Response.Write"<script>var totPaginas = " & iPageCount & ";var paginaActual=" & paginaActual & ";var indiceAnteriorMandado = '" & Request.Form("indiceAnterior") & "';</script>"
 CALL CierraDB2(DBMun)
%>
<script>
 //Se capturan variables de servidor necesarios para asegurar la correcta recursividad y seguimiento de la correcta p�ginaci�n
 var indiceActual = 0; //Registro seleccionado (sombreado)
 var indiceAnterior = 0; //Registro anterior del actual
 var antStyle = ''; //Estilo (CSS) del registro anterior
 var procesado = '<%= Request.Form("procesado") %>'; //Verifica si ya fue procesado el cat�logo (para evitar recargar el cat�logo sin necesidad)
 var iFrameFather = document.getElementById('iFrameFather'); //variable del iframe contenedor de este cat�logo
 var parentMaster = document.getElementById('parentMaster'); //IFRAME OVER IFRAME (si existe)
 var iFrameFatherX = ''; //auxiliar de iFrameFather
 var strParent = 'parent.'; //variable a usar (s�lo cambiara si existe parentMaster)
 if(parentMaster.value!='') strParent = parentMaster.value + '.';
 var campoCombo = eval(strParent+'document.all.item(\'<%= cmbTextPadre %>\')'); //campo en donde escribimos la informaci�n
 var campoIdCombo = eval(strParent+'document.all.item(\'<%= cmbIdPadre %>\')'); //campo donde se almacenara la clave del registro seleccionado
 var Catalogo = '<%= catalogo %>'; //nombre del cat�logo utilizado
 var resizeNewIFrame = '<%= Request.Form("resizeNewIFrame") %>'; //Verificar� si es necesario actualizar el tama�o del cat�logo y la posici�n de este desde lo invoquemos
 var refrescarVentana = 2;
 
 //inicializa variables
 indiceAnterior = -1;
 indiceAnterior2 = -1;
 
 //Determina la posici�n del objeto padre
 function Point(iX, iY){
	this.x = iX;
	this.y = iY;
 }
 
 function fGetXY(aTag){
  var pt = new Point(aTag.offsetLeft, aTag.offsetTop);
  do {
  	aTag = aTag.offsetParent;
  	pt.x += aTag.offsetLeft;
  	pt.y += aTag.offsetTop;
  } while(aTag.tagName!='BODY');
  return pt;
 }
 
 //Actualiza el tama�o de un iframe o un layer (s�lo si aplica y existe la variable iframe dentro de nuestra p�gina padre)
 function resizeParent() { 	
  if(parent.iframe)
   parent.parent.resizeIFrame(parent.iframe);   
  if(parent.ilayer)
   parent.parent.resizeILayer(parent.ilayer);
 }
 
 //Funci�n que detecta si hacemos clic en la p�gina que invoquemos el cat�logo y esconderlo, s�lo en IFRAME OVER IFRAME
 if(parentMaster.value!='parent') {
  arrayStrParent = parentMaster.value.split('.');
  if(arrayStrParent.length==2) {
   var objetoParentMasterX = eval(parentMaster.value);
   objetoParentMasterX.document.onmousedown=function(e){
    if(objetoParentMasterX.esconderFrame ==1) {
     objetoParentMasterX.esconderFrame =0;
	 parent.document.getElementById(iFrameFather.value).style.visibility='hidden';
	}
   }
  }
 }
 
 //funci�n principal
 function verificaCatalogo2(catalogo,cmbPadre,cmbId,iFrameFather,accion,ancho,alto,condicion,accionJavaScript,evento,paginacionX,evento2,targetAux,showFooter,parentMaster) {
  
  var bandera = true;
  var resFrame = false;
  if(!parentMaster) //VERIFICAR SI LO LLAMO OTRO PADRE (IFRAME OVER IFRAME)
	 parentMaster = 'parent';
	 
  try { //new
   var cmbPadreObject = eval(parentMaster+'.document.all.item(\''+cmbPadre+'\')');
   if(campoCombo!= cmbPadreObject) {
    Catalogo = '';   
   }
  }
  
  catch(err) {}
  if(bandera) {
   if(catalogo!=Catalogo) {
    var iFrameFatherObject = eval('parent.document.getElementById(\''+iFrameFather+'\')');
    iFrameFatherObject.style.width = parseInt(ancho)+20;
    iFrameFatherObject.style.height = parseInt(alto)+20;
    document.getElementById('catalogo').value = catalogo;
    document.getElementById('cmbTextPadre').value = cmbPadre;
    document.getElementById('cmbIdPadre').value = cmbId;
    document.getElementById('accion').value = accion;
	document.getElementById('resizeNewIFrame').value = '1';
    document.getElementById('ancho').value = ancho;
    document.getElementById('alto').value = alto;
	document.getElementById('parentMaster').value = parentMaster;
	if(showFooter)
	 document.getElementById('showFooter').value = showFooter;
	else
	 document.getElementById('showFooter').value = '1';
    document.getElementById('condicion').value = condicion;
    document.getElementById('accionJavaScript').value = accionJavaScript;
    document.getElementById('iFrameFather').value = iFrameFather;
	valorAux='';
	var valorAuxObject = eval(parentMaster+'.document.getElementById(\''+cmbPadre+'\')');
	valorAux = valorAuxObject.value+valorAux;
	valorAux = valorAuxObject.value;	
	document.getElementById('CampoMostrar').value = valorAux;
    document.getElementById('procesado').value = 1;
    document.getElementById('pagina').value = 1; 
    if(!paginacionX)
     paginacionX = 100;
    document.getElementById('paginacionX').value = paginacionX;
	resFrame = true;
    submitForm(targetAux);
	return false;
   }
   else {
    if(evento==9 || evento==13)
	 procesa(indiceAnterior);
	 else
   
    if(evento2 && resFrame==false) {
     procesaId(false,1,resFrame);
	}
    else
	 if(resFrame==false)
      procesaId(evento,false,resFrame);
   }
  }
 }
  
 function procesa(elemento) {
  if (antStyle!='' && indiceAnterior!=-1)
	bodytable.rows(indiceAnterior).className ='ContenidoDynamicCombo'
  var layerA = document.getElementById('alay'+elemento).innerText;
  var layerB = document.getElementById('blay'+elemento).innerText;
  campoIdCombo.value = layerA;
  campoCombo.value = layerB;
  indiceAnterior = elemento;
  indiceAnterior2 = elemento;
  antStyle = bodytable.rows(indiceAnterior).style.backgroundColor ;
  bodytable.rows(indiceAnterior).className ='SeleccionDynamicCombo'
  iFrameFatherX.style.visibility='hidden';
  <%= Request("accionJavaScript") %>
   if(campoCombo.enabled)
    campoCombo.focus();
 }
 
 function enviar(pagina) {
  document.getElementById('CampoMostrar').value = campoCombo.value.toLowerCase();
  document.getElementById('procesado').value = 1;
  document.getElementById('pagina').value = pagina; 
  submitForm();
 }
 
 function submitForm(targetAux) {
  document.frmComboBox.method = 'post';
  document.frmComboBox.target = '_self';
  document.frmComboBox.action = '<%= request.ServerVariables("URL") %>';
  if(targetAux)
   document.frmComboBox.action =targetAux;
  document.frmComboBox.submit(); 
 }
 
 function verificaTxtPag(evento,objeto,paginaActual,iPageCount) {
  if(evento.keyCode==13) {
   if (!isNaN(objeto.value)) {
    valor = parseInt(objeto.value);
    if(valor>iPageCount || valor<1)
	 alert('N�mero de p�gina incorrecto');
	else {
	 if(valor!=paginaActual)
	  enviar(objeto.value);
	}
   }
   else
    alert('El n�mero de p�gina debe ser num�rico');
  }
 }
 
 function procesaId(evento,tecla2,resizeIframeGo) {
  campoCombo.focus();
  var teclaAux = '';
  var tecla = '';
  if(evento)
   tecla = evento
  else  
   if (tecla2)
    tecla = tecla2;
  teclaAux = '';

  if(indiceAnterior==<%= i-1 %> && tecla==40) //nuevo
   if(totPaginas>paginaActual) {
    enviar(paginaActual+1);
    return true;
   }
   
  if(tecla==38 && indiceAnterior==0) //nuevo
   if(paginaActual!=1) {
    document.getElementById('indiceAnterior').value =document.getElementById('paginacionX').value;
    enviar(paginaActual-1);
    return true;
   }

  if(indiceAnteriorMandado!='') {  //nuevo
   indiceAnterior2 = parseInt(indiceAnteriorMandado)-1;
   indiceAnterior = parseInt(indiceAnteriorMandado)-2;
   indiceAnteriorMandado = '';
   tecla = 40;
  }
  var itop = 0;
  var ileft = 0;
  iFrameFatherX = eval('parent.document.getElementById(\''+iFrameFather.value+'\')');
  
  if(resizeIframeGo) { //s�lo entra si es nuevo el campo que solicita el cat�logo para actualizar tama�o y posici�n
   var point = fGetXY(campoCombo);
   with (iFrameFatherX.style) {  
    if(parentMaster.value!='parent') {
     arrayStrParent = parentMaster.value.split('.');
	 if(arrayStrParent.length==2) {
	  var objetoParentMaster = parent.document.getElementById(arrayStrParent[1]);
      itop = objetoParentMaster.offsetTop;
	  ileft = objetoParentMaster.offsetLeft;
	 }
    }
    left = ileft+point.x;
    top  = itop+point.y+campoCombo.offsetHeight+3;
   }
   resizeParent();
  }
  iFrameFatherX.style.visibility = "visible";
  
  if ((tecla==13||tecla==9) && indiceAnterior!=-1) {
   procesa(indiceAnterior);
  }
  else
   if (tecla!=38 && tecla!=40) {
    tecla = 40;
    for (i=0;i<=<%= i-1 %>;i++) {
     var index = document.getElementById('blay'+i).innerText.toLowerCase().indexOf(campoCombo.value.toLowerCase()+teclaAux);
	 if(index==0) {
      indiceAnterior = i-1;
	  indiceAnterior2 = i-1;
	  antStyle = bodytable.rows(i).style.backgroundColor ;
	  tecla = 40;
	  break;
     }
    }
	if(index!=0) {
     indiceAnterior = -1;
	 indiceAnterior2 = -1;
	 if(tecla2!=1) {
	  document.getElementById('CampoMostrar').value = campoCombo.value.toLowerCase()+teclaAux;
	  document.getElementById('procesado').value = 1;
      document.getElementById('pagina').value = 1; 
      submitForm();
	 }
   }
  }
  
  if (tecla == 38 || tecla == 40) {
   indiceAnterior2 = indiceAnterior; 
   layCatalogo.style.visibility = 'visible';
   if (tecla==40) {
    if(indiceAnterior < <%= i-1 %>)
	 indiceAnterior = indiceAnterior+1;
   }
	else {
	 if(indiceAnterior>0)
	  indiceAnterior = indiceAnterior-1;
  }
  for (i=0;i<=<%= i-1 %>;i++)
   bodytable.rows(i).className = 'ContenidoDynamicCombo';
  if(indiceAnterior2!=indiceAnterior) {
   layCatalogo.scrollTop =bodytable.rows(indiceAnterior).offsetTop;
  }
  if(indiceAnterior!=-1)
  bodytable.rows(indiceAnterior).className ='SeleccionDynamicCombo';   
 }
}

if (procesado=='1') {
 if(resizeNewIFrame=='1')
  procesaId(false,1,true);
 else
   procesaId(false,1,false);
}

function verifyAction() {
 if(refrescarVentana==0) {
  verificaCatalogo2(fnCatcatalogo,fnCatcmbPadre,fnCatcmbId,fnCatiFrameFather,fnCataccion,fnCatancho,fnCatalto,fnCatcondicion,fnCataccionJavaScript,fnCatevento,fnCatpaginacionX,fnCatevento2,fnCattargetAux,fnCatshowFooter,fnCatparentMaster)
  refrescarVentana = 2;
 }
 if(refrescarVentana==1) {
  refrescarVentana = 0;
 }
  var timerID = setTimeout('verifyAction()',200);
}

 var fnCatcatalogo,fnCatcmbPadre,fnCatcmbId,fnCatiFrameFather,fnCataccion,fnCatancho;
 var fnCatalto,fnCatcondicion,fnCataccionJavaScript,fnCatevento,fnCatpaginacionX,fnCatevento2;
 var fnCattargetAux,fnCatshowFooter,fnCatparentMaster;

function verificaCatalogo(catalogo,cmbPadre,cmbId,iFrameFather,accion,ancho,alto,condicion,accionJavaScript,evento,paginacionX,evento2,targetAux,showFooter,parentMaster) {
 fnCatcatalogo=catalogo;
 fnCatcmbPadre=cmbPadre;
 fnCatcmbId=cmbId;
 fnCatiFrameFather=iFrameFather;
 fnCataccion=accion;
 fnCatancho=ancho;
 fnCatalto=alto;
 fnCatcondicion=condicion;
 fnCataccionJavaScript=accionJavaScript;
 if(evento)
  evento = evento.keyCode;
 fnCatevento=evento;
 fnCatpaginacionX=paginacionX;
 fnCatevento2=evento2;
 fnCattargetAux=targetAux;
 fnCatshowFooter=showFooter;
 fnCatparentMaster=parentMaster;
 refrescarVentana = 1;
 
 //if(evento2 || fnCatevento==9 || fnCatevento==13) refrescarVentana = 0;

}

function procesaASPCatalogue(ASPCatalogue) {
 campoCombo.focus();
 if(document.getElementById('alay'+indiceAnterior))
  var auxIdCombo = document.getElementById('alay'+indiceAnterior).innerText;
 else
  var auxIdCombo = '';
 var strToSend = '';
 var mainArray = ASPCatalogue.split('?');
 if(mainArray.length==1) {
  strToSend = ASPCatalogue + '?campoToSend='+campoCombo.value+ '&idCampoToSend='+auxIdCombo+'&invocoCatalogo=1';
 }
 else {
  strToSend = mainArray[0];
  var auxArray = mainArray[1].split('&');
  if(auxArray.length==1)
   strToSend = strToSend + '?'+mainArray[1] + '&campoToSend='+campoCombo.value+'&idCampoToSend='+auxIdCombo+'&invocoCatalogo=1';
  else {
   var auxStrToSend = '';
   for(var n=0;n<auxArray.length;n++)
    auxStrToSend = auxStrToSend + '&'+ auxArray[n];
   strToSend = strToSend + '?campoToSend='+campoCombo.value+'&idCampoToSend='+auxIdCombo+'&invocoCatalogo=1'+auxStrToSend;
  }
 }
 var ventana = window.open(strToSend,'auxiliarCatalogo','status=yes,dependent=yes,scrollbars=yes');   
 ventana.top.window.resizeTo(screen.availWidth,screen.availHeight);
 ventana.focus();
}

function procesaAspCatalogue2(RequestIdValor,RequestValor) {
 campoCombo.value = RequestValor;
 campoIdCombo.value = RequestIdValor;
 <%= Request("accionJavaScript") %>
 if(campoCombo.enabled)
  campoCombo.focus();
 refrescarVentana = 2;
 iFrameFatherX.style.visibility='hidden';
 
 //verificaCatalogo2(fnCatcatalogo,fnCatcmbPadre,fnCatcmbId,fnCatiFrameFather,fnCataccion,fnCatancho,fnCatalto,fnCatcondicion,fnCataccionJavaScript,fnCatevento,fnCatpaginacionX,fnCatevento2,fnCattargetAux,fnCatshowFooter,fnCatparentMaster)
}

 verifyAction();
</script>