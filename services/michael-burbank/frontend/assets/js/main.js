document.addEventListener('DOMContentLoaded', function () {
    const statusBanner = document.getElementById('status-banner');
    const uptimeMichaelBurbank = document.getElementById('uptime-michael-burbank');
    const michaelBurbankServerStatus = document.getElementById('michael-burbank-service-status');

    if (!uptimeMichaelBurbank) {
        console.log('Missing uptime elements, skipping uptime fetch.');
        return;
    }

    async function fetchMichaelBurbankUptime_Endpoint() {
        try {
            // # represents endpoint URL placeholder for AWS API Gateway
            const response = await fetch('#');
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            console.log('Michael Burbank uptime data:', data);
            uptimeMichaelBurbank.textContent = data.uptime_percentage;
        }
        catch (error) {
            console.error('Error fetching Michael Burbank uptime:', error);
            statusBanner.textContent = "Degraded Performance Detected";
            statusBanner.classList.add('down');
            statusBanner.classList.remove('up');

            uptimeMichaelBurbank.textContent = 'Offline';
            michaelBurbankServerStatus.textContent = 'DOWN';
            michaelBurbankServerStatus.classList.remove('up');
            michaelBurbankServerStatus.classList.add('down');

            return;
        }
    };

    fetchMichaelBurbankUptime_Endpoint();


});