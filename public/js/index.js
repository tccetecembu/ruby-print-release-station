var pricePerPage = 0
var pricePerPrint = 0

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

function resumeJob(id) {
    actionJob("resume", id);
}

function cancelJob(id) {
    actionJob("cancel", id);
}

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
