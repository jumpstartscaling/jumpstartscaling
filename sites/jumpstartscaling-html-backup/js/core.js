// Jumpstart Scaling - Core Survey Logic
// Pure vanilla JS - no frameworks needed

let currentStep = 0;
const answers = {};
const totalSteps = 5;

// Capture UTM parameters on page load
window.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    ['utm_source', 'utm_medium', 'utm_campaign'].forEach(key => {
        if (params.get(key)) answers[key] = params.get(key);
    });
    answers.page_url = window.location.href;
});

// Handle option selection
window.selectOption = (key, value) => {
    answers[key] = value;
    console.log('Selected:', key, value);
    nextStep();
};

// Move to next step
window.nextStep = () => {
    const steps = document.querySelectorAll('.survey-step');

    if (currentStep < totalSteps - 1) {
        // Hide current step
        steps[currentStep].classList.add('hidden');

        // Show next step
        currentStep++;
        steps[currentStep].classList.remove('hidden');

        // Update progress bar
        const percent = ((currentStep + 1) / totalSteps) * 100;
        document.getElementById('progress-fill').style.width = `${percent}%`;
    }
};

// Move to previous step
window.prevStep = () => {
    const steps = document.querySelectorAll('.survey-step');

    if (currentStep > 0) {
        // Hide current step
        steps[currentStep].classList.add('hidden');

        // Show previous step
        currentStep--;
        steps[currentStep].classList.remove('hidden');

        // Update progress bar
        const percent = ((currentStep + 1) / totalSteps) * 100;
        document.getElementById('progress-fill').style.width = `${percent}%`;
    }
};

// Submit form
window.submitForm = () => {
    // Grab final inputs
    answers.name = document.getElementById('input-name').value;
    answers.email = document.getElementById('input-email').value;
    answers.phone = document.getElementById('input-phone').value;

    // Validation
    if (!answers.name || !answers.email || !answers.phone) {
        alert('Please fill in all fields');
        return;
    }

    // Add timestamp
    answers.submittedAt = new Date().toISOString();
    answers.userAgent = navigator.userAgent;

    // Log to console
    console.log('⚡ LEAD CAPTURED:', answers);

    // Save to localStorage as backup
    const existingLeads = JSON.parse(localStorage.getItem('jumpstart_leads') || '[]');
    existingLeads.push(answers);
    localStorage.setItem('jumpstart_leads', JSON.stringify(existingLeads));


    // Send to SQLite database via API
    fetch('/api/submit-lead', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(answers)
    })
        .then(response => response.json())
        .then(data => console.log('✅ Saved to database:', data))
        .catch(err => {
            console.warn('⚠️ API failed (lead saved to localStorage):', err);
        });


    // Show success message
    document.querySelectorAll('.survey-step').forEach(step => step.classList.add('hidden'));
    document.getElementById('success-message').classList.remove('hidden');
    document.getElementById('success-name').textContent = answers.name.split(' ')[0];
    document.getElementById('success-phone').textContent = answers.phone;

    // Update progress to 100%
    document.getElementById('progress-fill').style.width = '100%';
};
