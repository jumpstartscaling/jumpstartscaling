// Enhanced Survey Questions for Jumpstart Scaling
const surveySteps = [
    {
        step: 1,
        question: "What's your biggest challenge right now?",
        type: "radio",
        name: "challenge",
        options: [
            "Getting consistent leads",
            "Delivering quality without me",
            "Building/managing a team",
            "I'm working 60+ hours/week",
            "Profit margins are shrinking"
        ]
    },
    {
        step: 2,
        question: "What's your current annual revenue?",
        type: "radio",
        name: "revenue",
        options: [
            "$250k - $500k",
            "$500k - $1M",
            "$1M - $5M",
            "$5M - $10M",
            "$10M+"
        ]
    },
    {
        step: 3,
        question: "How many people are on your team?",
        type: "radio",
        name: "team_size",
        options: [
            "Just me (solo)",
            "2-5 people",
            "6-10 people",
            "11-25 people",
            "25+ people"
        ]
    },
    {
        step: 4,
        question: "What services are you most interested in?",
        type: "checkbox",
        name: "services",
        options: [
            "Leads & Paid Ads",
            "Funnels & Websites",
            "Automation & CRM",
            "Tracking & Reporting",
            "Compliance & Security",
            "Full-Service Marketing"
        ]
    },
    {
        step: 5,
        question: "What's your current monthly ad spend?",
        type: "radio",
        name: "ad_spend",
        options: [
            "$0 - $5k",
            "$5k - $15k",
            "$15k - $50k",
            "$50k+",
            "Not running ads yet"
        ]
    },
    {
        step: 6,
        question: "What industry are you in?",
        type: "select",
        name: "industry",
        options: [
            "Marketing Agency",
            "SaaS/Software",
            "E-commerce",
            "Consulting",
            "Professional Services",
            "Construction/Trades",
            "Healthcare",
            "Other"
        ]
    },
    {
        step: 7,
        question: "Your Contact Information",
        type: "contact",
        fields: [
            { name: "first_name", label: "First Name", type: "text" },
            { name: "last_name", label: "Last Name", type: "text" },
            { name: "email", label: "Email Address", type: "email" },
            { name: "phone", label: "Phone Number", type: "tel" },
            { name: "best_time", label: "Best time to call?", type: "select", options: ["Morning (8am-12pm)", "Afternoon (12pm-5pm)", "Evening (5pm-8pm)"] }
        ]
    }
];

// n8n Webhook Configuration
const N8N_WEBHOOK_URL = "YOUR_N8N_WEBHOOK_URL_HERE"; // Replace with actual webhook

// Form submission handler
async function submitToN8N(formData) {
    try {
        const response = await fetch(N8N_WEBHOOK_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });
        return response.ok;
    } catch (error) {
        console.error('Webhook error:', error);
        return false;
    }
}
