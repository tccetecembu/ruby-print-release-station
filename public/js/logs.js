/**
 * @file Funções relacionadas a página de relatórios de impressão.
 *
 * @author Ramon Dantas
 * @license MIT
 */

/**
 * Atualiza os logs que são mostrados na tabela.
 * @param {Object[]} jobs - Os trabalhos, lidos da API.
 */
function updateJobs(jobs) {
	html = "<tr>";
	html += "<th class='id'>ID</th>";
 	html += "<th class='title'>Título</th>";
	html += "<th class='owner'>Dono do trabalho</th>";
	html += "<th class='price'>Preço</th>";
	jobs.forEach(function(job) {
		html += "<tr>";
		html += "<td class='id'>"+job.id+"</td>";
		html += "<td class='title'>"+job.jobTitle+"</td>";
		html += "<td class='owner'>"+job.jobOwner+"</td>";
		html += "<td class='price'>"+job.price.formatMoney(2)+"</td>";
		html += "</tr>";
	})
	
	table = document.getElementById('logsTable');
	if (jobs.length > 0) {
		table.innerHTML = html;
		$('#logsTable').show();
		$('#nojobs').hide();				
	} else {
		// Mostrar a mensagem do div #nojobs		
		$('#logsTable').hide();
		$('#nojobs').show();
	}
}

/**
 * Callback do botão de mostrar logs do dia de hoje.
 */
function onShowTodayLogsClicked() {
	$("#doubleDateSelector").hide();
	$("#singleDateSelector").hide();

	$.ajax({
		type: 'GET',
		url: '/api/logs/today',
		dataType: 'json',
		success: function(data) {
			updateJobs(data);
		}
	})
}

/**
 * Callback do botão de mostrar logs de um dia.
 */
function onShowUniqueDayLogsClicked() {
	$("#doubleDateSelector").hide();
	$("#singleDateSelector").show();
	updateSingleDayLog();
}

/**
 * Callback do botão de mostrar um período de dias.
 */
function onShowMultipleDaysLogsClicked() {
	$("#singleDateSelector").hide();
	$("#doubleDateSelector").show();
	updateMultipleDayLog();
}

/**
 * Converter data para o formato YYYY/MM/DD.
 *
 * @param {string} date Data, parseável pela classe Date.
 * @returns {string} Data no formato YYYY/MM/DD.
 */
function formatDateToYYYYMMDD(date) {
	obj = new Date(date);
	// Meses vão de 0 a 11
	// ??????
	return obj.getFullYear() + "/" + (obj.getMonth()+1) + "/" + obj.getDate();
}

/**
 * Converter data de DD/MM/YYYY para YYYY/MM/DD.
 *
 * @param {string} date Data no formato DD/MM/YYYY.
 * @returns {string} Data no formato YYYY/MM/DD.
 */
function DDMMYYYYtoYYYYMMDD(date) {
	arr = date.split("/");
	return arr[2] + "/" + arr[1] + "/" + arr[0];
}

/**
 * Atualiza os logs baseado no seletor de data de dia único.
 */
function updateSingleDayLog() {
	date = $('#singleDateSelector .input-group').datepicker('getDate');
	if (date != null) {
		$.ajax({
			type: 'GET',
			url: '/api/logs/day/'+formatDateToYYYYMMDD(date),
			dataType: 'json',
			success: function(data) {
				updateJobs(data);
			}
		})
	}
}

/**
 * Atualiza os logs baseado no seletor de data de dia múltiplo.
 */
function updateMultipleDayLog() {
	startdate = $('#doubleDateSelector .input-daterange input[name="start"]').val();
	console.log(startdate);
	enddate = $('#doubleDateSelector .input-daterange input[name="end"]').val();
	console.log(enddate);
	
	if (startdate != "" && enddate != "") {
		$.ajax({
			type: 'GET',
			url: '/api/logs/daysRange/'+DDMMYYYYtoYYYYMMDD(startdate)+"/"+DDMMYYYYtoYYYYMMDD(enddate),
			dataType: 'json',
			success: function(data) {
				updateJobs(data);
			}
		})
	}
}

$(document).ready(function() {
	onShowTodayLogsClicked(); // Modo padrão, ativá-lo.
	
	opts = {
	    format: "dd/mm/yyyy",
	    language: "pt-BR",
		endDate: "0d",
		todayHighlight: true,
		autoclose: true
	};
	
	$('#singleDateSelector .input-group').datepicker(opts);
	
	$('#doubleDateSelector .input-daterange').datepicker(opts);
});
