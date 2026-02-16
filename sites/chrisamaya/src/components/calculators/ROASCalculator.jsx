import React, { useState, useEffect } from 'react';

const ROASCalculator = () => {
    const [spend, setSpend] = useState(5000);
    const [cpc, setCpc] = useState(2.50);
    const [convRate, setConvRate] = useState(2.0);
    const [aov, setAov] = useState(150);

    const [metrics, setMetrics] = useState({
        clicks: 0,
        conversions: 0,
        revenue: 0,
        roas: 0,
        profit: 0
    });

    useEffect(() => {
        const clicks = spend / cpc;
        const conversions = clicks * (convRate / 100);
        const revenue = conversions * aov;
        const roas = spend > 0 ? revenue / spend : 0;
        const profit = revenue - spend;

        setMetrics({
            clicks: Math.round(clicks),
            conversions: Math.round(conversions),
            revenue: Math.round(revenue),
            roas: roas.toFixed(2),
            profit: Math.round(profit)
        });
    }, [spend, cpc, convRate, aov]);

    const formatCurrency = (val) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(val);

    return (
        <div className="roas-calculator-card">
            <div className="calc-header">
                <h3>💰 ROAS Projection Engine</h3>
                <p>See how small improvements compound into massive profit.</p>
            </div>

            <div className="calc-grid">
                <div className="inputs">
                    <div className="input-group">
                        <label>Monthly Ad Spend: {formatCurrency(spend)}</label>
                        <input type="range" min="1000" max="50000" step="500" value={spend} onChange={(e) => setSpend(Number(e.target.value))} />
                    </div>

                    <div className="input-group">
                        <label>Cost Per Click (CPC): {formatCurrency(cpc)}</label>
                        <input type="range" min="0.50" max="20.00" step="0.10" value={cpc} onChange={(e) => setCpc(Number(e.target.value))} />
                    </div>

                    <div className="input-group">
                        <label>Conversion Rate: {convRate}%</label>
                        <input type="range" min="0.1" max="10.0" step="0.1" value={convRate} onChange={(e) => setConvRate(Number(e.target.value))} />
                    </div>

                    <div className="input-group">
                        <label>Avg Order Value: {formatCurrency(aov)}</label>
                        <input type="range" min="50" max="2000" step="50" value={aov} onChange={(e) => setAov(Number(e.target.value))} />
                    </div>
                </div>

                <div className="results">
                    <div className="result-item">
                        <span>Projected Revenue</span>
                        <div className="result-value gold">{formatCurrency(metrics.revenue)}</div>
                    </div>

                    <div className="result-item">
                        <span>ROAS</span>
                        <div className={`result-value ${metrics.roas > 3 ? 'green' : metrics.roas > 1.5 ? 'yellow' : 'red'}`}>
                            {metrics.roas}x
                        </div>
                    </div>

                    <div className="result-item highlight">
                        <span>Net Profit (Ad Spend)</span>
                        <div className="result-value">{formatCurrency(metrics.profit)}</div>
                    </div>
                </div>
            </div>

            <style jsx>{`
        .roas-calculator-card {
          background: rgba(255,255,255,0.03);
          border: 1px solid rgba(255,255,255,0.1);
          border-radius: 12px;
          padding: 2rem;
          margin: 3rem 0;
          font-family: 'Inter', sans-serif;
        }
        .calc-header h3 { color: #C9A961; margin-bottom: 0.5rem; }
        .calc-header p { color: #888; font-size: 0.9rem; margin-bottom: 2rem; }
        
        .calc-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 3rem; }
        @media (max-width: 768px) { .calc-grid { grid-template-columns: 1fr; } }

        .input-group { margin-bottom: 1.5rem; }
        .input-group label { display: block; color: #ccc; margin-bottom: 0.5rem; font-size: 0.9rem; font-weight: 600; }
        
        input[type=range] {
          width: 100%;
          accent-color: #C9A961;
          background: #333;
          height: 6px;
          border-radius: 3px;
        }

        .result-item {
          background: rgba(0,0,0,0.3);
          border: 1px solid rgba(255,255,255,0.05);
          padding: 1.5rem;
          border-radius: 8px;
          margin-bottom: 1rem;
          text-align: center;
        }
        
        .result-item.highlight {
          background: rgba(201, 169, 97, 0.1);
          border-color: #C9A961;
        }

        .result-item span { display: block; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; color: #888; margin-bottom: 0.5rem; }
        .result-value { font-size: 2rem; font-weight: 900; color: #fff; }
        .gold { color: #FFD700; }
        .green { color: #4ade80; }
        .yellow { color: #facc15; }
        .red { color: #f87171; }
      `}</style>
        </div>
    );
};

export default ROASCalculator;
