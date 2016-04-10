function reloadJobs() {
    jobs = document.getElementById("jobs");
    $.ajax({
        type: 'GET',
        url: '/api/list',
        dataType: 'json',
        success: function(data) {
            html = "<tr>";
            html += "<th class='jobId'>ID</th>"
            html += "<th class='title'>Titulo</th>";
            html += "<th class='pages'>Páginas</th>";
            html += "<th class='resumeCancel' colspan=2>Ações</th>";
            html += "</tr>";
            data.forEach(function(job) {
                html += "<tr>"
                html += "<td class='jobId'>"+job.id+"</span>";
                html += "<td class='title'>"+job.title+"</span>";
                html += "<td class='pages'>"+job.pageCount+"</span>";
                html += "<td class='resumeLink'><a href='#' onclick='resumeJob("+job.id+")'>Continuar</a></td>";
                html += "<td class='cancelLink'><a href='#' onclick='cancelJob("+job.id+")'>Cancelar</span></td>";
                html += "</tr>";
            });
            jobs.innerHTML = html;
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

Zepto(function($) {
    reloadJobs();
    setInterval(reloadJobs, 5000);
})
