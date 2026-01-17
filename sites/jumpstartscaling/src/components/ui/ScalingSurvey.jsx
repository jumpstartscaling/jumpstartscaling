import React, { useState } from 'react';

const ScalingSurvey = ({ webhookUrl }) => {
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState({
    industry: '',
    revenue: '',
    team: '',
    bottleneck: '',
    name: '',
    email: '',
    phone: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const questions = [
    {
      key: 'industry',
      question: "What type of business are you scaling?",
      type: 'grid',
      options: [
        { label: "E-Commerce", icon: "🛍️" },
        { label: "B2B / SaaS", icon: "💻" },
        { label: "Service Agency", icon: "🤝" },
        { label: "Local Business", icon: "📍" }
      ]
    },
    {
      key: 'revenue',
      question: "Where is your current monthly revenue?",
      type: 'grid',
      options: [
        { label: "< $10k/mo", icon: "🌱" },
        { label: "$10k - $50k", icon: "🚀" },
        { label: "$50k - $200k", icon: "🏢" },
        { label: "$200k+", icon: "🦄" }
      ]
    },
    {
      key: 'team',
      question: "What does your marketing team look like?",
      type: 'grid',
      options: [
        { label: "Just Me (Founder)", icon: "👤" },
        { label: "Freelancers", icon: "🎨" },
        { label: "Small In-House", icon: "👥" },
        { label: "Full Department", icon: "🏢" }
      ]
    },
    {
      key: 'bottleneck',
      question: "What is your biggest blocker right now?",
      type: 'grid',
      options: [
        { label: "Lead Quality", icon: "📉" },
        { label: "Ad Performance", icon: "💸" },
        { label: "Tech / CRM", icon: "⚙️" },
        { label: "Sales Process", icon: "📞" }
      ]
    },
    {
      key: 'contact',
      question: "Where should we send your Growth Audit?",
      type: 'input'
    }
  ];

  const handleOptionClick = (val) => {
    setAnswers({ ...answers, [questions[step].key]: val });
    nextStep();
  };

  const handleInput = (e) => {
    const { name, value } = e.target;
    setAnswers({ ...answers, [name]: value });
  };

  const nextStep = () => {
    if (step < questions.length - 1) {
      setStep(step + 1);
    } else {
      submitForm();
    }
  };

  const submitForm = async () => {
    setIsSubmitting(true);
    try {
      if (webhookUrl) {
        await fetch(webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(answers)
        });
      }
      // Simulate delay for interaction
      setTimeout(() => {
        setIsSubmitting(false);
        setIsSuccess(true);
      }, 1500);
    } catch (e) {
      console.error(e);
      setIsSubmitting(false);
    }
  };

  if (isSuccess) {
    return (
      <div className="survey-container success-state">
        <div className="success-icon">✅</div>
        <h3>Application Received</h3>
        <p>Thanks {answers.name.split(' ')[0]}. check your email for our contact card.</p>
        <p className="highlight-text">Chris will be personally reviewing your audit and calling you shortly.</p>
      </div>
    );
  }

  const currentQ = questions[step];
  const progress = ((step + 1) / questions.length) * 100;

  return (
    <div className="survey-container">
      <div className="progress-bar">
        <div className="fill" style={{ width: `${progress}%` }}></div>
      </div>

      <div className="question-area">
        <div className="header-row">
          <span className="step-count">Question {step + 1} of {questions.length}</span>
          {step > 0 && <button className="back-btn" onClick={() => setStep(step - 1)}>Back</button>}
        </div>

        <h2>{currentQ.question}</h2>

        {currentQ.type === 'grid' ? (
          <div className="options-grid">
            {currentQ.options.map((opt, i) => (
              <button key={i} className="option-card" onClick={() => handleOptionClick(opt.label)}>
                <span className="opt-icon">{opt.icon}</span>
                <span className="opt-label">{opt.label}</span>
              </button>
            ))}
          </div>
        ) : (
          <div className="input-area">
            <div className="form-group">
              <label>Full Name</label>
              <input
                type="text" name="name" placeholder="John Doe"
                value={answers.name} onChange={handleInput}
              />
            </div>

            <div className="form-group">
              <label>Best Email</label>
              <input
                type="email" name="email" placeholder="john@company.com"
                value={answers.email} onChange={handleInput}
              />
            </div>

            <div className="form-group">
              <label>Direct Phone</label>
              <input
                type="tel" name="phone" placeholder="(555) 123-4567"
                value={answers.phone} onChange={handleInput}
              />
              <small className="privacy-note">🔒 We do not text promos. This is only for Chris to call you.</small>
            </div>

            <div className="info-box">
              <p><strong>Next Steps:</strong> We will email you our contact info immediately. Chris will call you at this number to discuss your audit results.</p>
            </div>

            <button className="submit-btn" onClick={submitForm} disabled={!answers.email || !answers.name || !answers.phone}>
              {isSubmitting ? "Submitting Application..." : "Complete Application"}
            </button>
          </div>
        )}
      </div>

      <style jsx>{`
        .survey-container {
          background: #050505;
          border: 1px solid rgba(255,255,255,0.1);
          border-radius: 16px;
          padding: 3rem;
          max-width: 800px; /* Wider for grid */
          margin: 0 auto;
          position: relative;
          overflow: hidden;
          min-height: 450px;
          display: flex;
          flex-direction: column;
          /* justify-content: center; Remove vertical centering to handle taller forms nicely */
          font-family: 'Inter', sans-serif;
          box-shadow: 0 30px 60px rgba(0,0,0,0.6);
        }

        .progress-bar {
          position: absolute;
          top: 0; left: 0; width: 100%; height: 4px; background: #222;
        }

        .fill {
          height: 100%; background: #C9A961; transition: width 0.4s ease;
        }
        
        .header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; }
        .step-count { color: #666; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 2px; }
        .back-btn { background: none; border: none; color: #666; cursor: pointer; text-decoration: underline; font-size: 0.8rem; }

        h2 {
          color: #fff; font-size: 1.8rem; margin: 0.5rem 0 2rem; line-height: 1.2;
        }

        /* CARD GRID STYLES */
        .options-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1.5rem;
        }
        
        .option-card {
          background: rgba(255,255,255,0.03);
          border: 1px solid rgba(255,255,255,0.1);
          padding: 2rem;
          border-radius: 12px;
          cursor: pointer;
          transition: all 0.2s;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 1rem;
          text-align: center;
        }
        
        .option-card:hover {
          border-color: #C9A961;
          background: rgba(201, 169, 97, 0.05);
          transform: translateY(-3px);
          box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }
        
        .opt-icon { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .opt-label { color: #e0e0e0; font-size: 1.1rem; font-weight: 500; }

        /* FORM INPUT STYLES */
        .input-area { display: flex; flex-direction: column; gap: 1.25rem; }
        
        .form-group label { display: block; color: #888; font-size: 0.9rem; margin-bottom: 0.5rem; }
        
        input {
          width: 100%;
          background: #111; border: 1px solid #333;
          padding: 0.9rem; color: #fff; border-radius: 6px; font-size: 1rem;
          font-family: inherit;
        }
        
        input:focus { outline: none; border-color: #C9A961; background: #151515; }
        
        .privacy-note { display: block; color: #555; font-size: 0.8rem; margin-top: 0.5rem; }
        
        .info-box {
          background: rgba(201, 169, 97, 0.1);
          border-left: 3px solid #C9A961;
          padding: 1rem;
          border-radius: 4px;
          margin: 0.5rem 0;
        }
        
        .info-box p { color: #ddd; font-size: 0.9rem; margin: 0; line-height: 1.5; }

        .submit-btn {
          background: #C9A961; color: #000; border: none; padding: 1.2rem;
          font-weight: 700; font-size: 1.1rem; border-radius: 6px; cursor: pointer;
          margin-top: 0.5rem; transition: background 0.3s;
        }
        .submit-btn:hover { background: #e0bd6f; }
        .submit-btn:disabled { background: #444; color: #888; cursor: not-allowed; }

        /* SUCCESS STATE */
        .success-state { align-items: center; text-align: center; justify-content: center; }
        .success-icon { font-size: 4rem; margin-bottom: 1.5rem; }
        .success-state h3 { font-size: 2rem; color: #fff; margin-bottom: 1rem; }
        .success-state p { color: #aaa; margin-bottom: 0.5rem; }
        .highlight-text { color: #C9A961 !important; font-weight: bold; margin-top: 1rem; font-size: 1.1rem; }

        @media (max-width: 600px) {
          .options-grid { grid-template-columns: 1fr; gap: 0.8rem; }
          .option-card { padding: 1.5rem; flex-direction: row; text-align: left; }
          .survey-container { padding: 1.5rem; }
        }
      `}</style>
    </div>
  );
};

export default ScalingSurvey;
