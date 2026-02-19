document.addEventListener('DOMContentLoaded', function () {
    const statusBanner = document.getElementById('status-banner');
    const uptimeMichaelBurbank = document.getElementById('uptime-michael-burbank');
    const michaelBurbankServerStatus = document.getElementById('michael-burbank-service-status');

    // REST ENDPOINT URL - UPDATE TO API ENDPOINT WHEN READY
    const API_URL = '#';

    if (!statusBanner || !uptimeMichaelBurbank || !michaelBurbankServerStatus) {
        console.log('Missing required DOM elements, skipping uptime fetch.');
        return;
    }

    function setUpState(uptimePercentage) {
        statusBanner.textContent = 'All Systems Operational';
        statusBanner.classList.add('up');
        statusBanner.classList.remove('down');

        michaelBurbankServerStatus.textContent = 'UP';
        michaelBurbankServerStatus.classList.add('up');
        michaelBurbankServerStatus.classList.remove('down');

        uptimeMichaelBurbank.textContent =
            typeof uptimePercentage === 'number'
                ? `${uptimePercentage.toFixed(2)}%`
                : '--';
    }

    function setDownState() {
        statusBanner.textContent = 'Degraded Performance Detected';
        statusBanner.classList.add('down');
        statusBanner.classList.remove('up');

        uptimeMichaelBurbank.textContent = 'Offline';
        michaelBurbankServerStatus.textContent = 'DOWN';
        michaelBurbankServerStatus.classList.remove('up');
        michaelBurbankServerStatus.classList.add('down');
    }

    async function fetchMichaelBurbankUptimeEndpoint() {
        try {
            const response = await fetch(API_URL, { method: 'GET', cache: 'no-store' });
            if (!response.ok) throw new Error(`HTTP ${response.status}`);

            const data = await response.json();
            console.log('Michael Burbank uptime data:', data);

            // Expected shape: { up: boolean, uptime_percentage: number }
            if (data.up === true) {
                setUpState(data.uptime_percentage);
            } else {
                setDownState();
            }
        } catch (error) {
            console.error('Error fetching Michael Burbank uptime:', error);
            setDownState();
        }
    }

    fetchMichaelBurbankUptimeEndpoint();
});