/**
 * @file Funções para a tela de controle da liberação de impressão (index.html).
 * 
 * @author Ramon Dantas
 * @license MIT
 */

var pricePerBwPage = 0;
var pricePerColorPage = 0;
var pricePerPrint = 0;
var config = null;

/**
 * Calcula o preço da impressão, baseado nos valores definidos em pricePerBwPage, pricePerColorPage e pricePerPrint
 *
 * @param {Integer} totalPages Numero total de páginas
 * @param {Integer} colorPages Número de páginas coloridas
 * @returns Valor da impressão.
 */
function calculatePrice(totalPages, colorPages) {
	return pricePerPrint + colorPages * pricePerColorPage + (totalPages - colorPages) * pricePerBwPage;
}

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
                html += "<td class='pages'>"+(job.pageCount == null ? "Calculando..." : job.pageCount)+"</span>";
                html += "<td class='price'>"+(job.pageCount == null || job.colorPages == null ? "Calculando..." : "R$ " + calculatePrice(job.pageCount, job.colorPages).formatMoney(2))+"</span>";
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
			
			// Gente q faz merda faz merda
			if (job.pageCount == 999) {
				alert("Parabéns, você não tem vida.");
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
 * Atualiza os preços nas variáveis pricePerBwPage, pricePerColorPage e pricePerPrint
 */
function getPrices() {
    $.ajax({
        type: 'GET',
        url: '/api/price/page/bw',
        dataType: 'json',
        success: function(data) {
            pricePerBwPage = data;
        }
    });
	
	$.ajax({
		type: 'GET',
		url: '/api/price/page/color',
		dataType: 'json',
		success: function(data) {
			pricePerColorPage = data;
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

/**
 * Altera os valores dos inputs da janela de configuração baseado na variavel config.
 */
function fillSettingsWindow() {
	$("input[name='price_per_bw_page']").attr("value", config["price_per_bw_page"])
	$("input[name='price_per_color_page]").attr("value", config["price_per_color_page"])
	$("input[name='log_printing']").prop("checked", config["log_printing"])	
}

/**
 * Carrega as configurações do serviço de controle de impressão e abre a janela de configuração.
 */
function openSettingsWindow() {
	$.ajax({
		type: 'GET',
		url: '/api/config',
		dataType: 'json',
		success: function(data) {
			config = data;
			fillSettingsWindow();
			$("#settings_window").show();
		}
	})
}

/**
 * Função para converter texto em moeda que nem um retardado pode fazer dar errado. Eu acho.
 *
 * @param {String} text O texto a ser convertido
 * @returns {Float} O texto convertido em moeda
 */
function retardProofTextToMoney(text) {
	text = text.replace(/[.,](?=[^.,]*[.,])/g, "")
	text = text.replace(",", ".")
	text = text.replace(/[^0-9.]/g, "")
	return Number.parseFloat(text)
}

/**
 * Envia as configurações da janela de configuração.
 */
function submitSettings() {
	config["price_per_bw_page"] = retardProofTextToMoney($("input[name='price_per_bw_page']").attr("value"))
	config["price_per_color_page"] = retardProofTextToMoney($("input[name='price_per_color_page']").attr("value"))
	config["log_printing"] = $("input[name='log_printing']").is(":checked")
	
	$.post('/api/config',
		{ config: JSON.stringify(config) },
		function(data) {
			getPrices();
		}
	)
}

$(document).ready(function() {
    getPrices();
    reloadJobs();
	changeBackground();
	
    setInterval(reloadJobs, 5000);
})
