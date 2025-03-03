import React from "react";

export default function AboutPage() {
  return (
    <div className="flex flex-col min-h-screen bg-background text-foreground transition duration-300">
      {/* Hero Section */}
      <div className="bg-navbar-footer dark:bg-navbar-footer-dark text-heading dark:text-white py-12 transition duration-300">
        <h1 className="text-5xl font-bold text-center">About Us</h1>
        <p className="text-lg text-center mt-4 max-w-3xl mx-auto">
          Empowering minds through engaging games designed to enhance mental
          agility and well-being for the elderly.
        </p>
      </div>

      {/* Main Content */}
      <div className="max-w-5xl mx-auto py-12 px-6 text-text dark:text-white">
        {/* Our Mission */}
        <section className="mb-12">
          <h2 className="text-3xl font-semibold mb-4 text-heading dark:text-white">
            Our Mission
          </h2>
          <p className="text-lg leading-relaxed">
            Our mission is to support cognitive health and foster an active mind
            for older adults through fun, interactive, and accessible exercise
            games. We believe in creating opportunities for mental growth,
            happiness, and connection in every stage of life.
          </p>
        </section>

        {/* How We Help */}
        <section className="mb-12">
          <h2 className="text-3xl font-semibold mb-4 text-heading dark:text-white">
            How We Help
          </h2>
          <ul className="text-lg leading-relaxed space-y-4 list-disc pl-6">
            <li>
              <span className="font-semibold">Cognitive Engagement:</span> Our
              games are designed to stimulate memory, problem-solving, and
              attention skills.
            </li>
            <li>
              <span className="font-semibold">Tailored Experiences:</span>{" "}
              Activities are specifically designed to be accessible, enjoyable,
              and challenging at appropriate levels for older users.
            </li>
            <li>
              <span className="font-semibold">Community Connection:</span>{" "}
              Encouraging interaction through multiplayer games or sharing
              progress with family and friends.
            </li>
          </ul>
        </section>

        {/* Why Choose Us */}
        <section className="mb-12">
          <h2 className="text-3xl font-semibold mb-4 text-heading dark:text-white">
            Why Choose Us?
          </h2>
          <div className="bg-lightCard dark:bg-darkCard p-6 rounded-lg shadow-sm transition duration-300">
            <p className="text-lg">
              We understand the unique needs of the elderly when it comes to
              technology and cognitive health. Our platform offers:
            </p>
            <ul className="text-lg leading-relaxed space-y-4 list-disc pl-6 mt-4">
              <li>
                Simple, elder-friendly designs with clear instructions and
                intuitive navigation.
              </li>
              <li>
                Customizable game difficulty levels to cater to varying
                cognitive abilities.
              </li>
              <li>
                Backed by research in cognitive science and developed in
                consultation with experts in aging and mental health.
              </li>
            </ul>
          </div>
        </section>

        {/* Looking Ahead */}
        <section>
          <h2 className="text-3xl font-semibold mb-4 text-heading dark:text-white">
            Looking Ahead
          </h2>
          <p className="text-lg leading-relaxed">
            As we continue to grow, our goal is to expand our library of games
            and incorporate new features that further promote mental wellness,
            physical health, and social connection. Together, we can create a
            brighter future for cognitive health and well-being.
          </p>
        </section>
      </div>
    </div>
  );
}
