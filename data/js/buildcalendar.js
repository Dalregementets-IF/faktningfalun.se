/* vim: set noexpandtab ts=2 sw=2: */
function pad(val) {
	if (val < 10) {
		return '0' + val
	} else {
		return val
	}
}
function buildCalendar(dlpath) {
	document.addEventListener('DOMContentLoaded', () => {
		const dialog = document.querySelector('#calendar-modal')
		const dialogTitle = document.querySelector('#calendar-modal h3')
		const dialogTime = document.querySelector('#calendar-modal p')
		document.querySelector('#calendar-modal button').addEventListener('click', () => {dialog.close()})
		const cal = new FullCalendar.Calendar(document.getElementById('calendar'), {
			headerToolbar: {
				start: 'prev,next today',
				center: 'title',
				end: 'dayGridMonth,dayGridWeek,listWeek'
			},
			customButtons: {
				download: {
					text: 'Ladda ner kalender',
					click: () => {window.location = dlpath}
				}
			},
			initialView: 'dayGridMonth',
			weekNumbers: true,
			locale: 'sv',
			eventClick: (info) => {
				let startDate = cal.formatDate(info.event.start, {})
				let time = startDate + '\u{2003}'
				if (info.event.allDay) {
					time += 'Hela dagen'
				} else {
					time += pad(info.event.start.getHours()) + ':' + pad(info.event.start.getMinutes())
					if (info.event.end !== null) {
					  let endDate = cal.formatDate(info.event.end, {})
						time += '\u{2013}'
						if (startDate !== endDate) time += endDate + ' '
					  time += pad(info.event.end.getHours()) + ':' + pad(info.event.end.getMinutes())
					}
				}
				dialogTitle.innerText = info.event.title
				dialogTime.innerText = time
				dialog.showModal()
			},
		})
		cal.render()
		$.get(dlpath).then((data) => {
			var c = new ICAL.Component(ICAL.parse(data.trim()))
			var events = $.map(c.getAllSubcomponents('vevent'), (item) => {
				if(item.getFirstPropertyValue('class') == 'PRIVATE'){
					return null
				} else {
					var res = {
						'title': item.getFirstPropertyValue('summary'),
						'location': item.getFirstPropertyValue('location'),
					};
					var rrule = item.getFirstPropertyValue('rrule')
					if (rrule != null) {
						//event recurs
						res.rrule = {}
						if (rrule.freq) res.rrule.freq = rrule.freq
						if (rrule.parts.BYDAY) res.rrule.byweekday = rrule.parts.BYDAY
						if (rrule.until) res.rrule.until = rrule.until.toString()
						if (rrule.interval) res.rrule.interval = rrule.interval
						var dtstart = item.getFirstPropertyValue('dtstart').toString()
						var dtend = item.getFirstPropertyValue('dtend').toString()
						res.rrule.dtstart = dtstart
						//count duration ms
						var startdate = new Date(dtstart)
						var enddate = new Date(dtend)
						res.duration = enddate - startdate
					} else {
						if (item.hasProperty('dtstart') && item.hasProperty('dtend')) {
							res.start = item.getFirstPropertyValue('dtstart').toString()
							res.end = item.getFirstPropertyValue('dtend').toString()
						} else {
							return null
						}
					}
					return res
				}
			})
			cal.setOption('events', events)
			if (events.length > 0) cal.setOption('footerToolbar', {end:'download'})
		})
	})
}
