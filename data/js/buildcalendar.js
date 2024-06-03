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
		const dialogTitle = document.querySelector('#calendar-modal-title')
		const dialogDate = document.querySelector('#calendar-modal-date')
		const dialogPlace = document.querySelector('#calendar-modal-location')
		const dialogDesc = document.querySelector('#calendar-modal-description')
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
			timeZone: 'UTC',
			locale: 'sv',
			eventClick: (info) => {
				let startDate = cal.formatDate(info.event.start, {})
				let time = startDate + '\u{2003}'
				if (info.event.allDay) {
					time += 'Hela dagen'
				} else {
					time += pad(info.event.start.getUTCHours()) + ':' + pad(info.event.start.getUTCMinutes())
					if (info.event.end !== null) {
					  let endDate = cal.formatDate(info.event.end, {})
						time += '\u{2013}'
						if (startDate !== endDate) time += endDate + ' '
					  time += pad(info.event.end.getUTCHours()) + ':' + pad(info.event.end.getUTCMinutes())
					}
				}
				dialogTitle.innerText = info.event.title
				dialogDate.innerText = time
				dialogPlace.innerText = info.event.extendedProps.location
				dialogDesc.innerHTML = info.event.extendedProps.description.replace('\n', '<br>')
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
						'description': item.getFirstPropertyValue('description'),
						'categories': item.getFirstPropertyValue('categories'),
					};
					var rrule = item.getFirstPropertyValue('rrule')
					if (rrule != null) {
						//event recurs
						res.rrule = {}
						if (rrule.freq) res.rrule.freq = rrule.freq
						if (rrule.parts.BYDAY) res.rrule.byweekday = rrule.parts.BYDAY
						if (rrule.until) res.rrule.until = rrule.until.toString().substring(0,11) + '23:59:59' // ugly hack to work around Z timezone
						if (rrule.interval) res.rrule.interval = rrule.interval
						res.rrule.dtstart = item.getFirstPropertyValue('dtstart').toString()
						//count duration ms
						let ds = new Date(res.rrule.dtstart)
						let de = new Date(item.getFirstPropertyValue('dtend').toString())
						res.duration = de - ds
						//exclusions
						let exdate = item.getAllProperties('exdate')
						if (exdate.length > 0) {
							res.exdate = []
							for (i = 0; i < exdate.length; i++) {
								res.exdate.push(exdate[i].getFirstValue().toString())
							}
						}
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
