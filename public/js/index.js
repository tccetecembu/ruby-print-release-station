/**
 * @file Funções para a tela de controle da liberação de impressão (index.html).
 * 
 * @author Ramon Dantas
 * @license MIT
 */

var pricePerPage = 0;
var pricePerPrint = 0;

/** Recarrega os trabalhos de impressão listados na table #jobs */
function reloadJobs() {
    jobs = document.getElementById("jobs");
    $.ajax({
        type: 'GET',
        url: '/api/list',
        dataType: 'json',
        success: function(data) {
            html = "<tr>";
            html += "<th class='jobId'>ID</th>"
            html += "<th class='title'>Título</th>";
            html += "<th class='pages'>Páginas</th>";
            html += "<th class='price'>Preco</th>";
            html += "<th class='resumeCancel' colspan=2>Ações</th>";
            html += "</tr>";
            data.forEach(function(job) {
                html += "<tr>"
                html += "<td class='jobId'>"+job.id+"</span>";
                html += "<td class='title'>"+job.title+"</span>";
                html += "<td class='pages'>"+job.pageCount+"</span>";
                html += "<td class='price'>R$ "+(pricePerPrint + pricePerPage*job.pageCount).formatMoney(2);+"</span>";
                html += "<td class='resumeLink'><a href='#' onclick='resumeJob("+job.id+")'>Continuar</a></td>";
                html += "<td class='cancelLink'><a href='#' onclick='cancelJob("+job.id+")'>Cancelar</span></td>";
                html += "</tr>";
            });
			
			if (data.length > 0) {
				jobs.innerHTML = html;
				$('#jobs').show();
				$('#nojobs').hide();				
			} else {
				$('#jobs').hide();
				$('#nojobs').show();
			}
        }
    });
}

/**
 * Realiza uma ação com um job, recarregando os trabalhos de impressão logo após.
 *
 * @param {string} action A ação a ser feita (resume, cancel)
 * @param {Integer} id O ID do trabalho.
 */
function actionJob(action, id) {
    $.ajax({
        type: 'GET',
        url: '/api/'+action+'/'+id,
        dataType: 'json',
        success: function(data) {
            reloadJobs();
        }
    });
}

/**
 * Continua um job, recarregando os trabalhos de impressão logo após.
 *
 * @param {Integer} id O ID do trabalho.
 */
function resumeJob(id) {
    actionJob("resume", id);
}

/**
 * Cancela um job, recarregando os trabalhos de impressão logo após.
 *
 * @param {Integer} id O ID do trabalho.
 */
function cancelJob(id) {
    actionJob("cancel", id);
}

/**
 * Atualiza os preços nas variáveis pricePerPage e pricePerPrint
 */
function getPrices() {
    $.ajax({
        type: 'GET',
        url: '/api/price/page',
        dataType: 'json',
        success: function(data) {
            pricePerPage = data;
        }
    });

    $.ajax({
        type: 'GET',
        url: '/api/price/print',
        dataType: 'json',
        success: function(data) {
            pricePerPrint = data;
        }
    });
}

/**
 * Muda o plano de fundo da página, obtendo um novo plano de fundo a partir da API.
 */
function changeBackground() {
	$.ajax({
		type: 'GET',
		url: '/api/images/getRandomBackground',
		dataType: 'text',
		success: function(data) {
			$('body').css('background-image', 'url('+data+')');
		}
	})
}

$(document).ready(function() {
    getPrices();
    reloadJobs();
	changeBackground();
	
    setInterval(reloadJobs, 5000);
})
